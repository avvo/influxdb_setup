module InfluxdbSetup
  class Command
    def initialize(config)
      @config = config
    end

    def log(message)
      puts "[InfluxdbSetup] #{message}"
    end
  end
end
