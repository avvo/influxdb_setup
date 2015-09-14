module InfluxdbSetup
  class MarkDeploy < Command
    def call(commit)
      db = @config.db_name
      root = @config.build_client(db)

      root.write_point("deploys", {
        rails_env: config.env,
        commit: commit
      })

      log("Marked deploy: #{config.env} at sha #{commit}")
    end
  end
end
