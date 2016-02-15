module InfluxdbSetup
  class LoadQueries < Command
    def call
      db = @config.db_name
      root = @config.build_client(db)

      existing_queries = root.list_continuous_queries(db)
      expected_queries = YAML.load_file("db/influxdb_queries.yml")

      no_change = 0
      expected_queries.each_with_index do |query, index|
        unless existing_queries.map(&:query).include?(query)
          log "Adding '#{query}'"
          root.create_continuous_query("config_query_#{index}", db, query)
        else
          no_change += 1
        end
      end

      log "There were #{no_change} continuous queries that required no updates"

      existing_queries.each do |query|
        unless expected_queries.include?(query.query)
          log "Removing '#{query.name}':'#{query.query}'"
          root.delete_continuous_query(query.name, db)
        end
      end
    end
  end
end
