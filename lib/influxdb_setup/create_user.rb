module InfluxdbSetup
  class CreateUser < Command
    def call
      db = @config.db_name
      user = @config.username
      pass = @config.password

      root = @config.build_client
      users = root.list_users.map{|user_hash| user_hash["username"]}

      if user == nil
        log "Influxdb user not specified, using the default one..."
      elsif users.include?(user)
        log "Influxdb user '#{user}'@'#{db}' already exists"
      else
        root.create_database_user(db, user, pass)
      end
    end
  end
end
