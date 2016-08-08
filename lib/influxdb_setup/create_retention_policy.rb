module InfluxdbSetup
  class CreateRetentionPolicy < Command
    def call
      db = @config.db_name
      retention_policies = @config.retention_policies

      root = @config.build_client
      rcs = root.list_retention_policies(db).map { |row| row["name"] }

      retention_policies.each do |rc|
        if rcs.include? rc['name']
          root.alter_retention_policy(rc['name'], db, rc['duration'], rc['replication'])
        else
          root.create_retention_policy(rc['name'], db, rc['duration'], rc['replication'])
        end
      end
    end
  end
end
