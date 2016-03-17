# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).
CHANGELOG inspiration from http://keepachangelog.com/.

## Unreleased
* Update influxdb_queries.yml and LoadQueries for InfluxDB 0.10

## [0.4.1] - March 4, 2016
* Skip loading continuous queries if influxdb_queries.yml file doesn't exist.
* Use a real logger object, this will cause timestamps to be printed, and makes
  testing easier.
