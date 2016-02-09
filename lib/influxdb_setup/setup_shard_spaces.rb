module InfluxdbSetup
  class SetupShardSpaces < Command
    def call
      return log "Shard spaces not supported by latest Influxdb gem"
    end
  end
end
