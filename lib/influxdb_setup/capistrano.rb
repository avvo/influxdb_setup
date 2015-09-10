namespace :deploy do
  before :restart, :influxdb_setup do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env), newrelic_agent_enabled: false do
          execute :rake, 'influxdb:setup'
        end
      end
    end
  end
end
