require 'yaml'
require 'erb'

module InfluxdbSetup
  class Config
    class << self
      attr_writer :config
    end

    def self.config
      @config ||= YAML.load(ERB.new(File.read("config/influxdb.yml")).result)[env]
    end

    attr_accessor :logger

    def initialize
      @config = self.class.config
      @logger = Logger.new(STDOUT)
    end

    def env
      defined?(Rails) ? Rails.env : ENV.fetch('RAILS_ENV', 'development')
    end

    def db_name
      @config['db_name']
    end

    def enabled?
      @config['enabled']
    end

    def username
      @config['username']
    end

    def password
      @config['password']
    end

    def build_client(database = "", options = {})
      InfluxDB::Client.new(database,
                          {
                            username: "root",
                            password: "root",
                            hosts:    @config["hosts"],
                            port:     @config.fetch("port", 8086),
                            async:    false,
                            use_ssl:  @config.fetch("use_ssl", false),
                            retry:    false,
                          }.merge(options))
    end
  end
end
