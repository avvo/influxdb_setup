require "spec_helper"
require "stringio"

class ArrayLog
  def initialize(array)
    @array = array
  end

  def info(message)
    @array << message
  end
end

describe InfluxdbSetup::LoadQueries do
  let(:log) { [] }
  let(:logger) { ArrayLog.new(log) }
  let(:db) { 'influxdb_setup_test' }
  let(:config_hash) {{
    'db_name'  => db,
    'enabled'  => true,
    'username' => 'root',
    'password' => 'root',
    'hosts'    => ENV.fetch('INFLUXDB_HOSTS', 'localhost'),
    'port'     => ENV.fetch('INFLUXDB_PORT', 8086),
    'use_ssl'  => ENV.fetch('INFLUXDB_USE_SSL', false),
  }}
  let(:config) { InfluxdbSetup::Config.new config: config_hash, logger: logger }
  let(:client) { config.build_client }

  subject { described_class.new(config) }

  context "no influxdb_queries.yml file present" do
    it "logs that it is skipping the continuous query setup" do
      subject.call

      expect(log).
        to eq(["[InfluxdbSetup] No influxdb_queries.yml file found, skipping continuous queries setup"])
    end
  end

  context "file exists" do
    let(:filename) { "db/influxdb_queries.yml" }
    before do
      FileUtils.mkdir_p "db"
      File.write filename, file_contents
      client.create_database(db)
    end

    after do
      client.delete_database(db)
      FileUtils.rm(filename) if File.exists?(filename)
      FileUtils.rmdir "db"
    end

    describe "creating a query" do
      let(:file_contents) do
        <<-YAML
---
minnie:
  SELECT min(mouse) INTO min_mouse FROM zoo GROUP BY time(30m)
        YAML
      end

      it "logs that it's created" do
        subject.call

        expect(log).
          to eq([
            "[InfluxdbSetup] Adding 'minnie': 'SELECT min(mouse) INTO min_mouse FROM zoo GROUP BY time(30m)'",
          ])
      end

      it "saves the query to influxdb" do
        subject.call

        expect(client.list_continuous_queries(db)).
          to eq([
            {
              "name" => "influxdb_setup_minnie",
              "query" => "CREATE CONTINUOUS QUERY influxdb_setup_minnie ON influxdb_setup_test BEGIN SELECT min(mouse) INTO influxdb_setup_test.\"default\".min_mouse FROM influxdb_setup_test.\"default\".zoo GROUP BY time(30m) END"
            }
        ])
      end
    end

    describe "can't replace a query because you can't compare what's in influxdb with the yaml except by name" do
      let(:file_contents) do
        <<-YAML
---
minnie:
  SELECT min(mouse) INTO min_mouse FROM zoo GROUP BY time(30m)
        YAML
      end

      before do
        client.create_continuous_query("influxdb_setup_minnie",
                                       db,
                                       "SELECT max(mouse) INTO min_mouse FROM zoo GROUP BY time(30m)")
      end

      it "logs that it skipped it" do
        subject.call

        expect(log).
          to eq([
            "[InfluxdbSetup] Skipping 'minnie', a query by that name already exists",
          ])
      end

      it "makes no change to the query in influxdb" do
        subject.call

        expect(client.list_continuous_queries(db)).
          to eq([
            {
              "name" => "influxdb_setup_minnie",
              "query" => "CREATE CONTINUOUS QUERY influxdb_setup_minnie ON influxdb_setup_test BEGIN SELECT max(mouse) INTO influxdb_setup_test.\"default\".min_mouse FROM influxdb_setup_test.\"default\".zoo GROUP BY time(30m) END"
            }
        ])
      end
    end

    describe "no changes" do
      let(:file_contents) do
        <<-YAML
---
minnie:
  SELECT min(mouse) INTO min_mouse FROM zoo GROUP BY time(30m)
        YAML
      end

      before do
        client.create_continuous_query("influxdb_setup_minnie",
                                       db,
                                       "SELECT min(mouse) INTO min_mouse FROM zoo GROUP BY time(30m)")
      end

      it "logs that nothing changed" do
        subject.call

        expect(log).
          to eq([
            "[InfluxdbSetup] Skipping 'minnie', a query by that name already exists"
          ])
      end
    end

    describe "delete a query" do
      let(:file_contents) do
        <<-YAML
---
        YAML
      end

      before do
        client.create_continuous_query("influxdb_setup_minnie",
                                       db,
                                       "SELECT max(mouse) INTO min_mouse FROM zoo GROUP BY time(30m)")
      end

      it "logs that it deleted the query" do
        subject.call

        expect(log).
          to eq([
            "[InfluxdbSetup] Removing 'influxdb_setup_minnie', was: 'CREATE CONTINUOUS QUERY influxdb_setup_minnie ON influxdb_setup_test BEGIN SELECT max(mouse) INTO influxdb_setup_test.\"default\".min_mouse FROM influxdb_setup_test.\"default\".zoo GROUP BY time(30m) END'",
          ])
      end

      it "actually deletes the query" do
        subject.call

        expect(client.list_continuous_queries(db)).to eq([])
      end
    end

    describe "yaml is an array" do
      let(:file_contents) do
        <<-YAML
---
- SELECT min(mouse) INTO min_mouse FROM zoo GROUP BY time(30m)
        YAML
      end
      it "raises an error" do
        expect { subject.call }.to raise_error(InfluxdbSetup::LoadQueries::FileFormatError)
      end
    end

    describe "erb interpolationz" do
      let(:file_contents) do
        <<-YAML
---
minnie:
  SELECT <%= "min(moose)" %> INTO min_mouse FROM zoo GROUP BY time(30m)
        YAML
      end

      it "logs that it's created" do
        subject.call

        expect(log).
          to eq([
            "[InfluxdbSetup] Adding 'minnie': 'SELECT min(moose) INTO min_mouse FROM zoo GROUP BY time(30m)'",
          ])
      end

      it "saves the query to influxdb" do
        subject.call

        expect(client.list_continuous_queries(db)).
          to eq([
            {
              "name" => "influxdb_setup_minnie",
              "query" => "CREATE CONTINUOUS QUERY influxdb_setup_minnie ON influxdb_setup_test BEGIN SELECT min(moose) INTO influxdb_setup_test.\"default\".min_mouse FROM influxdb_setup_test.\"default\".zoo GROUP BY time(30m) END"
            }
        ])
      end
    end
  end
end
