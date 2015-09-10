# InfluxdbSetup

For configuring the influxdb database, shard spaces, and continuous queries.

## Installation

Add these lines to your application's Gemfile:

```ruby
source 'http://gems.corp.avvo.com'

gem 'influxdb_setup'
```

And then execute:

    $ bundle

## Usage

This library expects your influxdb config to be located in the
`config/influxdb.yml` file. For example (change *myapp* to your application
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


development:
  <<: *default
  hosts: ["192.168.59.103"]
  async: false
  enabled: true
  retry: false

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

To have the task run on deploy, add `require "influxdb_setup/capistrano"` to
your `config/deploy.rb`.

To add continuous queries, just add them to the `db/influxdb_queries.yml`, for
example:

```yaml
---
 - select * from "response_times" into response_times.[rails_env]
 - select mean(value),count(value),percentile(value,95.0) as 95th,percentile(value,99.0) as 99th from "response_times.production" group by time(1h) into archive.response_times.1h
```

Make sure your queries match what the server coerces them into (no spaces
after commas) by running the `rake influxdb:load_queries` task multiple times.
If there's queries to update the task will not do anything.

## Rake tasks

`rake influxdb:create_db`
Creates the database for the service if it doesn't already exist.

`rake influxdb:setup_shard_spaces`
Creates or updates the default and archives shard spaces. If they don't exist,
it creates them. If they do exist but they are not correct, it updates them.

`rake influxdb:create_user`
Creates the user for the service if it doesn't already exist.

`rake influxdb:load_queries`
Creates any continuous queries that are missing. Removes queries that are not
in the `db/influxdb_queries.yml` file.

`rake influxdb:setup`
Runs all the above rake tasks.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitLab at
https://gitlab.corp.avvo.com/avvo/influxdb_setup.


## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

