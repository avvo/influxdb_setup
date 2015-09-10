module InfluxdbSetup
  class CreateDb < Command
    def call
      db = @config.db_name
      root = @config.build_client
      databases = root.get_database_list.map { |row| row["name"] }

      unless databases.include?(db)
        root.create_database(db)
      else
        puts "Influxdb database '#{db}' already exists"
      end
    end
  end
end
