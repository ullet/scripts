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

class Accounts
  attr_reader :server_logins, :database_users

  def initialize(connection_strings_path)
    File.open(connection_strings_path, 'r') do |file|
      @server_logins = {}
      @database_users = {}
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
            end#
          end#
        end#
        if match
          db = match[1]
          uid = match[2]
          pwd = match[3]
          add_server_login(uid, pwd)
          add_database(db)
          add_db_for_login(uid, db)
        end
      end
    end
  end
  
  private
  
  def add_server_login(uid, pwd)
    server_logins[uid] = {:pwd => pwd, :dbs=>[]} unless server_logins[uid]
  end
  
  def add_database(db)
    database_users[db] = [] unless database_users[db]    
  end
  
  def add_db_for_login(uid, db)
    unless login_for_db?(uid, db)
      server_logins[uid][:dbs] << db 
      database_users[db] << uid
    end
  end
  
  def login_for_db?(uid, db)
    server_logins[uid][:dbs].any? {|d| d == db}
  end
end
