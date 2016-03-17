module InfluxdbSetup
  class LoadQueries < Command
    class Query
      attr_reader :raw_name, :query

      def initialize(raw_name, query)
        @raw_name = raw_name
        @query = query
      end

      def name
        "influxdb_setup_#{raw_name}"
      end
    end

    NotAHashError = Class.new(StandardError)

    def call
      queries_file = Pathname.new("db/influxdb_queries.yml")

      if queries_file.exist?
        db = @config.db_name
        root = @config.build_client(db)
        existing_queries = root.list_continuous_queries(db)
        raw = YAML.load_file(queries_file.to_s) || {}
        raise NotAHashError, "expected influxdb_queries.yml to be a hash, was a #{raw.class.name}" unless raw.is_a?(Hash)

        expected_queries = raw.map do |name, query|
          Query.new(name, query)
        end

        # Delete first in case an old name is getting overwritten
        existing_queries.each do |query|
          if expected_queries.none? {|expected| expected.name == query["name"]}
            log "Removing '#{query['name']}', was: '#{query['query']}'"
            root.delete_continuous_query(query["name"], db)
          end
        end

        expected_queries.each do |expected|
          if existing_queries.any? {|hash| hash["name"] == expected.name}
            log "Skipping '#{expected.raw_name}', a query by that name already exists"
          else
            log "Adding '#{expected.raw_name}': '#{expected.query}'"
            root.create_continuous_query(expected.name, db, expected.query)
          end
        end
      else
        log "No influxdb_queries.yml file found, skipping continuous queries setup"
      end
    end
  end
end
