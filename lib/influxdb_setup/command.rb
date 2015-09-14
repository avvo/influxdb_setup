module InfluxdbSetup
  class Command
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def log(message)
      puts "[InfluxdbSetup] #{message}"
    end
  end
end
