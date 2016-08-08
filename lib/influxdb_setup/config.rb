require 'yaml'
require 'erb'
require 'influxdb'

module InfluxdbSetup
  class Config
    class << self
      attr_writer :config
    end

    def self.config
      config_file = ENV.fetch('INFLUXDB_CONFIG_FILE', 'config/influxdb.yml')
      @config ||= YAML.load(ERB.new(File.read(config_file)).result)[env]
    end

    def self.env
      defined?(Rails) ? Rails.env : ENV.fetch('RAILS_ENV', 'development')
    end

    attr_accessor :logger

    def initialize(config: self.class.config, logger: Logger.new(STDOUT))
      @config = config
      @logger = logger
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

    def retention_policies
      @config['retention_policies']
    end

    def build_client(database = "", options = {})
      InfluxDB::Client.new(database,
                          {
                            username: @config.fetch('username', 'root'),
                            password: @config.fetch('password', 'root'),
                            hosts:    @config['hosts'],
                            port:     @config.fetch('port', 8086),
                            async:    @config.fetch('async', false),
                            use_ssl:  @config.fetch('use_ssl', false),
                            retry:    false,
                          }.merge(options))
    end
  end
end
