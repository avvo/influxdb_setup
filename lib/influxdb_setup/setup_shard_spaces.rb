module InfluxdbSetup
  class SetupShardSpaces < Command
    def call
      db = @config.db_name
      root = @config.build_client

      expected_default_config = {
        "name"              => "default",
        "database"          => db,
        "regex"             => "/.*/",
        "retentionPolicy"   => "7d",
        "shardDuration"     => "1h",
        "replicationFactor" => 1,
        "split"             => 1
      }

      expected_archive_config = {
        "name"              => "archives",
        "database"          => db,
        "regex"             => "/archive.*/",
        "retentionPolicy"   => "365d",
        "shardDuration"     => "7d",
        "replicationFactor" => 1,
        "split"             => 1
      }

      actual_default_shard = root.get_shard_space(db, "default")
      actual_archive_shard = root.get_shard_space(db, "archives")

      if actual_default_shard != expected_default_config
        log "Updating default shard space"
        root.update_shard_space(db, "default", expected_default_config.except("database"))
      else
        log "Shard default up to date"
      end

      if actual_archive_shard.nil?
        log "Creating archives shard space"
        root.create_shard_space(db, expected_archive_config.except("database"))
      elsif actual_archive_shard != expected_archive_config
        log "Updating archives shard space"
        root.update_shard_space(db, "archives", expected_archive_config.except("database"))
      else
        log "Shard archives up to date"
      end
    end
  end
end
