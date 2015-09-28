module InfluxdbSetup
  class Commands
    attr_reader :config

    def self.handle_errors(method_name)
      return warn "[InfluxdbSetup] requires Ruby 2.2 or greater" if method_name.nil?
      alias_method "original_#{method_name}", method_name
      define_method method_name do |*args|
        begin
          send("original_#{method_name}", *args)
        rescue InfluxDB::ConnectionError => e
          puts "[InfluxdbSetup##{method_name}] Skipping... #{e.message}"
        end
      end
    end

    def initialize
      @config = Config.new
    end

    handle_errors def create_db
      CreateDb.new(config).call if @config.enabled?
    end

    handle_errors def setup_shard_spaces
      SetupShardSpaces.new(config).call if @config.enabled?
    end

    handle_errors def create_user
      CreateUser.new(config).call if @config.enabled?
    end

    handle_errors def load_queries
      LoadQueries.new(config).call if @config.enabled?
    end

    handle_errors def mark_deploy(commit)
      MarkDeploy.new(config).call(commit) if @config.enabled?
    end
  end
end
