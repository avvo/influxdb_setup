module InfluxdbSetup
  class Commands
    attr_reader :config

    def initialize
      @config = Config.new
    end

    {
      create_db: CreateDb,
      create_user: CreateUser,
      create_retention_policy: CreateRetentionPolicy,
      load_queries: LoadQueries,
      mark_deploy: MarkDeploy,
    }.each do |cmd, klass|
      define_method cmd do |*args|
        begin
          klass.new(config).call(*args) if config.enabled?
        rescue InfluxDB::ConnectionError => e
          puts "[InfluxdbSetup##{cmd}] Skipping... #{e.message}"
        end
      end
    end
  end
end
