module InfluxdbSetup
  class LoadQueries < Command
    def call
      db = @config.db_name
      root = @config.build_client(db)
      url = root.send :full_url, "/cluster/configuration"
      configuration = root.send :get, url

      existing_queries = configuration["ContinuousQueries"][db].each_with_object({}) do |row, acc|
        acc[row['Id']] = row['Query']
      end
      expected_queries = YAML.load_file("db/influxdb_queries.yml")

      expected_queries.each do |query|
        unless existing_queries.values.include?(query)
          puts "Adding '#{query}'"
          root.query query
        end
      end

      existing_queries.each do |(id, query)|
        unless expected_queries.include?(query)
          puts "Removing '#{query}'"
          root.query "drop continuous query #{id}"
        end
      end
    end
  end
end
