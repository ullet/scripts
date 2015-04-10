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
  def initialize(accounts, options = {})
    @accounts = accounts
    @options = { login_mode: :create }.merge(options)
  end

  def generate
    [
      'USE [master]',
      accounts.server_logins.map do |username, data|
        login_sql(username, data)
      end,
      '',
      accounts.database_users.map { |db, users| fix_users_sql(users, db) },
      ''
    ].flatten.join("\n")
  end

  private

  attr_reader :accounts, :options

  def login_sql(username, data)
    (options[:login] == :alter ? 'ALTER' : 'CREATE') +
      " LOGIN #{username} WITH PASSWORD='#{data[:pwd]}'" +
      (options[:login] == :create ? ', CHECK_POLICY=OFF' : '')
  end

  def fix_users_sql(users, db)
    [
      "USE [#{db}]",
      users.map(&method(:fix_user_sql)),
      ''
    ].flatten
  end

  def fix_user_sql(user)
    "EXEC sp_change_users_login 'Auto_Fix', '#{user}'"
  end
end
