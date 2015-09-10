namespace :influxdb do
  task :config do
    @influxdb_setup = InfluxdbSetup::Commands.new
  end

  task :create_db => [:config] do
    @influxdb_setup.create_db
  end

  task :setup_shard_spaces => [:config] do
    @influxdb_setup.setup_shard_spaces
  end

  task :create_user => [:config] do
    @influxdb_setup.create_user
  end


  task :load_queries => [:config] do
    @influxdb_setup.load_queries
  end

  task :setup => [:create_db,
                  :setup_shard_spaces,
                  :create_user,
                  :load_queries]
end
