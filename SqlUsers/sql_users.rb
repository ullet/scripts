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

require_relative 'accounts'
require_relative 'arguments'
require_relative 'generator'

args = Arguments.new(ARGV)
if args.valid?
  puts Generator.new(Accounts.new(args[:path]), args[:options]).generate
else
  puts 'Please specify path of connection strings file'
end
