namespace :deploy do
  before :restart, :influxdb_setup do
    on roles(:db) do
      within release_path do
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
