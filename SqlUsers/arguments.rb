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

# crude command line argument parsing
class Arguments < Hash
  def initialize(args)
    path = nil
    options = {}
    if args && args.any?
      if args[0] == '--alter'
        if args[1]
          path = args[1]
          options[:login] = :alter
        end
      else
        path = args[0]
        if args[1] == '--alter'
          options[:login] = :alter
        end
      end
    end
    self[:path] = path
    self[:options] = options
  end
  
  def valid?
    !self[:path].nil?
  end
end
