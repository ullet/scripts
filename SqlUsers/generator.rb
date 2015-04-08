# Copyright (c) 2015 Trevor Barnett
# Released under the terms of the MIT License
# (http://opensource.org/licenses/MIT)

# ------------------------------------------------------------------------------
# Parse a .NET connection strings config file, containing SQL Server connection
# strings, and generate a script that:
#   1. Creates server logins for all users found in the file
#   2. For each database in the file links each used server login to the
#      orphaned database user.
#
# This script is intended as an aid to developers restoring a database backup
# to a local development server from another environment (e.g. (a sanitised copy
# of) the production database).
# ------------------------------------------------------------------------------

class Generator
  def initialize(connection_strings_file, options={})
    @connection_strings_file = connection_strings_file
    @options = {login_mode: :create}.merge(options)
  end

  def generate()
    lines = []

    File.open(connection_strings_file, 'r') do |file|
      users = {}
      db_users = {}
      while (line = file.gets)
        line.chomp
        pattern = 'initial catalog\s*=\s*([^;]+);.*?' +
                  'uid\s*=\s*([^;]+);.*?' +
                  'pwd\s*=\s*([^";]+)'
        match = (/#{pattern}/i).match line
        if not match
          pattern = 'database\s*=\s*([^;]+);.*?' +
                    'uid\s*=\s*([^;]+);.*?' +
                    'pwd\s*=\s*([^";]+)'
          match = (/#{pattern}/i).match line
          if not match
            pattern = 'initial catalog\s*=\s*([^;]+);.*?' +
                      'user id\s*=\s*([^;]+);.*?' +
                      'password\s*=\s*([^";]+)'
            match = (/#{pattern}/i).match line
            if not match
              pattern = 'database\s*=\s*([^;]+);.*?' +
                        'user id\s*=\s*([^;]+);.*?' +
                        'password\s*=\s*([^";]+)'
              match = (/#{pattern}/i).match line
            end
          end
        end
        if match
          db = match[1]
          uid = match[2]
          pwd = match[3]
          users[uid] = {:pwd => pwd, :dbs=>[]} unless users[uid]
          users[uid][:dbs] << db unless users[uid][:dbs].any? {|d| d == db}
          db_users[db] = [] unless db_users[db]
          db_users[db] << uid unless db_users[db].any? {|u| u == uid}
        end
      end
      lines << "USE [master]"
      users.each do |user, data|
        sql = 
          (options[:login] == :alter ? "ALTER" : "CREATE") +
          " LOGIN #{user} WITH PASSWORD='#{data[:pwd]}'" +
          (options[:login] == :create ? ", CHECK_POLICY=OFF" : "")
        lines << sql
      end
      lines << ''
      db_users.each do |db, users|
        lines << "USE [#{db}]"
        users.each do |user|
          lines << "EXEC sp_change_users_login 'Auto_Fix', '#{user}'"
        end
        lines << ''
      end
    end
    (lines << '').join("\n")
  end
  
  private
  
  attr_reader :connection_strings_file, :options
end
