namespace :influxdb do
  task :config do
    @influxdb_setup = InfluxdbSetup::Commands.new
  end

  desc "Creates the influxdb database unless it already exists"
  task :create_db => [:config] do
    @influxdb_setup.create_db
  end

  desc "Setup the default and archives shard spaces"
  task :setup_shard_spaces => [:config] do
    @influxdb_setup.setup_shard_spaces
  end

  desc "Creates the service's user if it doesn't exist"
  task :create_user => [:config] do
    @influxdb_setup.create_user
  end

  desc "Loads the continuous queries from db/influxdb_queries.yml"
  task :load_queries => [:config] do
    @influxdb_setup.load_queries
  end

  desc "Run all the tasks to setup influxdb for the service"
  task :setup => [:create_db,
                  :setup_shard_spaces,
                  :create_user,
                  :load_queries]
end
