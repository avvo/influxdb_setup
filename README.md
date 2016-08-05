# InfluxdbSetup

For configuring the influxdb database, and continuous queries.

## Installation

Add these lines to your application's Gemfile:

```ruby
gem 'influxdb_setup'
```

And then execute:

    $ bundle

## Capistrano Integration

To have the task run on deploy, add `require "influxdb_setup/capistrano"` to
your `config/deploy.rb`.

This will run the setup on deploy (creating database, user, and
continuous queries). It will also mark the deploy in the "deploys" table in
your influxdb. See the example `influxdb_queries.yml` for the archive queries.

## Usage

This library expects your influxdb config to be located in the
`config/influxdb.yml` file. You can also specify a config file
by using the CONFIG environment variable. For example (change
*myapp* to your application
name):

```yaml
default: &default
  hosts: <%= ENV.fetch('INFLUXDB_HOSTS', '').split(',') %>
  port: <%= ENV.fetch('INFLUXDB_PORT', '8086') %>
  db_name: <%= ENV.fetch('INFLUXDB_DB_NAME', 'myapp') %>
  username: <%= ENV.fetch('INFLUXDB_USER', 'myapp') %>
  password: <%= ENV.fetch('INFLUXDB_PASS', 'myapp') %>
  async: <%= ENV.fetch('INFLUXDB_ASYNC', 'true') == "true" %>       # default true
  retry: <%= ENV.fetch('INFLUXDB_RETRY', 'true') == "true" %>       # default true
  use_ssl: <%= ENV.fetch('INFLUXDB_USE_SSL', 'false') == "true" %>  # default false
  enabled: <%= ENV.fetch('INFLUXDB_ENABLED', 'false') == "true" %>  # default false
  retention_policies:
    - name: 'default'
      duration: '4w'
      replication: 1
    - name: 'archive'
      duration: 'INF'
      replication: 1

development:
  <<: *default
  hosts: ["192.168.59.103"]
  async: false
  enabled: true
  retry: false
  retention_policies:
   - name: 'default'
     duration: '4w'
     replication: 1
   - name: 'archive'
     duration: 'INF'
     replication: 1

ec2:
  <<: *default

test:
  <<: *default

stag:
  <<: *default
  hosts: ["fs2wad.prod.avvo.com"]
  enabled: true

production:
  <<: *default
  hosts: ["fs2wad.prod.avvo.com"]
  enabled: true

docker:
  <<: *default
```

To add continuous queries, just add them to the `db/influxdb_queries.yml`, for
example:

```yaml
---
stag_times:
  select median(value) as median,mean(value) as mean,count(value) as count into one_hour_stag_response_times from "response_times" where rails_env='stag' group by time(1h)
prod_times:
  select median(value) as median,mean(value) as mean,count(value) as count into one_hour_prod_response_times from "response_times" where rails_env='production' group by time(1h)
prod_deploys:
  select count(commit) as deploys into prod_deploys_per_hour from "deploys" where rails_env='production' group by time(1h)
stag_deploys:
  select count(commit) as deploys into stag_deploys_per_hour from "deploys" where rails_env='stag' group by time(1h)
```

Make sure your queries match what the server coerces them into (no spaces
after commas) by running the `rake influxdb:load_queries` task multiple times.
If there's queries to update the task will not do anything.

### ERB enabled continuous queries

The `db/influxdb_queries.yml` file is ERB-enabled, so you can de-duplicate some
metrics:

```yaml
---
prod_perc_95:
  SELECT count(value) as count, percentile("value", 95) AS overall, <%= %w[cache db].map {|name| "percentile(\"#{name}\", 95) AS #{name}" } %> INTO prod_perc_95 FROM "response_times" WHERE "rails_env"='production' GROUP BY time(30m)
```

## Rake tasks

`rake influxdb:create_db`
Creates the database for the service if it doesn't already exist.

`rake influxdb:create_user`
Creates the user for the service if it doesn't already exist.

`rake influxdb:create_retention_policy`
Creates retention policies if they don't exist and alters retention policies if they already exist.

`rake influxdb:load_queries`
Creates any continuous queries that are missing. Removes queries that are not
in the `db/influxdb_queries.yml` file.

`rake influxdb:setup`
Runs all the above rake tasks.

`CONFIG=/your/config/file/path rake influxdb:setup`
Use specified config file. Here ```setup``` could be any other tasks supported.

## Tests

To run the tests, you need an influxdb host setup. If you're not running it on
`localhost:8086`, you can specify where it's running with the `INFLUXDB_HOSTS`
and `INFLUXDB_PORT` environmental variables.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/avvo/influxdb_setup. Please update the CHANGELOG
**unreleased** section with your changes. Please do not update version file in
pull request.

## Release Process

1. The version.rb file should only ever be updated in master, don't update it in your branch.
2. Once changes have been merged to master:
3. Update CHANGELOG.md and version.rb file with new version. Commit as "Bump version".
4. Run `rake release`, which will create a git tag for the version, push git commits and tags.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

