namespace :deploy do
  # on rollback, repo_path is not set or is not present, so we can't do
  # the influxdb_setup task below
  before :rollback, :skip_influxdb do
    set :skip_influxdb_setup, true
  end

  before :restart, :influxdb_setup do
    on roles(:db) do
      unless fetch(:skip_influxdb_setup)
        within current_path do
          revision = fetch(:current_revision) do
            within(repo_path) do
              capture("cd #{repo_path} && git rev-parse --short HEAD")
            end
          end

          with rails_env: fetch(:rails_env), newrelic_agent_enabled: false do
            execute :rake, "influxdb:setup influxdb:mark_deploy[#{revision}]"
          end
        end
      end
    end
  end
end
