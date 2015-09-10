module InfluxdbSetup
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/influxdb_setup.rake"
    end
  end
end
