namespace :influxdb do
  task :config => [:environment] do
    @influxdb_setup = InfluxdbSetup::Commands.new
  end

  desc "Creates the influxdb database unless it already exists"
  task :create_db => [:config] do
    @influxdb_setup.create_db
  end

  desc "Creates the service's user if it doesn't exist"
  task :create_user => [:config] do
    @influxdb_setup.create_user
  end

  desc "Create the retention policies"
  task :create_retention_policy => [:config] do
    @influxdb_setup.create_retention_policy
  end

  desc "Loads the continuous queries from db/influxdb_queries.yml"
  task :load_queries => [:config] do
    @influxdb_setup.load_queries
  end

  desc "Log deploy in influxdb"
  task :mark_deploy, [:commit] => [:config] do |t, args|
    @influxdb_setup.mark_deploy(args[:commit])
  end

  desc "Run all the tasks to setup influxdb for the service"
  task :setup => [:create_db,
                  :create_user,
                  :create_retention_policy,
                  :load_queries]
end
