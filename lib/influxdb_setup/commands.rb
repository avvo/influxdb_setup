module InfluxdbSetup
  class Commands
    attr_reader :config

    def initialize
      @config = Config.new
    end

    def create_db
      CreateDb.new(config).call if @config.enabled?
    end

    def setup_shard_spaces
      SetupShardSpaces.new(config).call if @config.enabled?
    end

    def create_user
      CreateUser.new(config).call if @config.enabled?
    end

    def load_queries
      LoadQueries.new(config).call if @config.enabled?
    end
  end
end
