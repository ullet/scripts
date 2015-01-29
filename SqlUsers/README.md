# sql_users.rb
A simple script to parse a .NET connection strings config file, containing SQL Server connection strings, and generate a script that:

1. Creates server logins for all users found in the file
2. For each database in the file links each used server login to the orphaned database user.

This script is intended as an aid to developers restoring a database backup to a local development server from another environment (e.g. (a sanitised copy of) the production database).

## Usage

    ruby sql_users.rb path\to\connection_strings.config

By default will output to console.

## Example
  
If connection_strings.config contains:

    <?xml version="1.0"?>
    <connectionStrings>
      <add name="AdminDbAdminUser"
           connectionString="Data Source=DBServer;
                             Initial Catalog=AdminDb;
                             uid=AdminUser;
                             pwd=Password1"
                             providerName="System.Data.SqlClient"/>
      <add name="PublicDbAdminUser"
           connectionString="Data Source=DBServer;
                             Initial Catalog=PublicDb;
                             uid=AdminUser;
                             pwd=Password1"
                             providerName="System.Data.SqlClient"/>
      <add name="PublicDbPublicUser"
           connectionString="Data Source=DBServer;
                             Initial Catalog=PublicDb;
                             uid=PublicUser;
                             pwd=Password2"
                             providerName="System.Data.SqlClient"/>
    </connectionStrings>

Then script will output:

    USE [master]
    CREATE LOGIN AdminUser WITH PASSWORD='Password1', CHECK_POLICY=OFF
    CREATE LOGIN PublicUser WITH PASSWORD='Password2', CHECK_POLICY=OFF

    USE [AdminDb]
    EXEC sp_change_users_login 'Auto_Fix', 'AdminUser'

    USE [PublicDb]
    EXEC sp_change_users_login 'Auto_Fix', 'AdminUser'
    EXEC sp_change_users_login 'Auto_Fix', 'PublicUser'
