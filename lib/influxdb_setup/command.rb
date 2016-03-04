module InfluxdbSetup
  class Command
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def log(message)
      @config.logger.info "[InfluxdbSetup] #{message}"
    end
  end
end
