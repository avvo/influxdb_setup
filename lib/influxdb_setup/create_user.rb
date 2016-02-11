module InfluxdbSetup
  class CreateUser < Command
    def call
      db = @config.db_name
      user = @config.username
      pass = @config.password

      root = @config.build_client
      users = root.list_users.map{|user_hash| user_hash["username"]}

      unless users.include?(user)
        root.create_database_user(db, user, pass)
      else
        log "Influxdb user '#{user}'@'#{db}' already exists"
      end
    end
  end
end
