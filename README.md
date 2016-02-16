# InfluxdbSetup

For configuring the influxdb database, and continuous queries.

## Installation

Add these lines to your application's Gemfile:

```ruby
source 'http://gems.corp.avvo.com'

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

To add continuous queries, just add them to the `db/influxdb_queries.yml`, for
example:

```yaml
---
 - select * from "response_times" into response_times.[rails_env]
 - select mean(value),count(value),percentile(value,95.0) as 95th,percentile(value,99.0) as 99th from "response_times.production" group by time(1h) into archive.response_times.1h
 - select * from "deploys" into deploys.[rails_env]
 - select * from "deploys.production" into archive.deploys
```

Make sure your queries match what the server coerces them into (no spaces
after commas) by running the `rake influxdb:load_queries` task multiple times.
If there's queries to update the task will not do anything.

## Rake tasks

`rake influxdb:create_db`
Creates the database for the service if it doesn't already exist.

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

To cut a gem:

1. Bump the version in `lib/influxdb_setup/version.rb`
2. Build the gem `gem_push=no rake release`
3. Push to geminabox `gem inabox pkg/influxdb_setup-0.1.0.gem` (or whatever
version you just cut.)

## Contributing

Bug reports and pull requests are welcome on GitLab at
https://gitlab.corp.avvo.com/avvo/influxdb_setup.

## Changelog

v0.4.0 - Upgrade influxdb gem to handle InfluxDB v0.9.x and greater and remove shard space setup support
v0.3.1 - automatically skip influxdb setup on a rollback
v0.3.0 - added the ability to skip influxdb setup by setting the capistrano variable skip_influx_setup


## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

