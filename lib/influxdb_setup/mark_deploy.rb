module InfluxdbSetup
  class MarkDeploy < Command
    def call(commit)
      db = @config.db_name
      root = @config.build_client(db)

      root.write_point("deploys", values: {
        rails_env: Config.env,
        commit: commit
      })

      log("Marked deploy: #{Config.env} at sha #{commit}")
    end
  end
end
