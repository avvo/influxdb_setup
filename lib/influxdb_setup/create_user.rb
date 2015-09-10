module InfluxdbSetup
  class CreateUser < Command
    def call
      db = @config.db_name
      user = @config.username
      pass = @config.password

      root = @config.build_client
      users = root.get_database_user_list(db).map { |row| row["name"] }

      unless users.include?(db)
        root.create_database_user(db, user, pass)
      else
        log "Influxdb user '#{user}'@'#{db}' already exists"
      end
    end
  end
end
