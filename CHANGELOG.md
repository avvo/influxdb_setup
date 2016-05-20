# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).
CHANGELOG inspiration from http://keepachangelog.com/.

## Unreleased

## [1.0.1] - May 20, 2016
* Fix Config.env method to be class, so that Config.config works if you don't set it first.

## [1.0.0] - April 8, 2016
* Public release

## [0.5.0] - March 17, 2016
* Update influxdb_queries.yml and LoadQueries for InfluxDB 0.10

## [0.4.1] - March 4, 2016
* Skip loading continuous queries if influxdb_queries.yml file doesn't exist.
* Use a real logger object, this will cause timestamps to be printed, and makes
  testing easier.

## [0.4.0]
* Upgrade influxdb gem to handle InfluxDB v0.9.x and greater and remove shard space setup support

## [0.3.1]
* automatically skip influxdb setup on a rollback

## [0.3.0]
* added the ability to skip influxdb setup by setting the capistrano variable skip_influx_setup
