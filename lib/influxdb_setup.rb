require "influxdb_setup/version"

module InfluxdbSetup
  autoload :Command, "influxdb_setup/command"
  autoload :Commands, "influxdb_setup/commands"
  autoload :Config, "influxdb_setup/config"
  autoload :CreateDb, "influxdb_setup/create_db"
  autoload :CreateUser, "influxdb_setup/create_user"
  autoload :LoadQueries, "influxdb_setup/load_queries"
  autoload :MarkDeploy, "influxdb_setup/mark_deploy"
  autoload :SetupShardSpaces, "influxdb_setup/setup_shard_spaces"
end

require "influxdb_setup/railtie" if defined?(Rails)
