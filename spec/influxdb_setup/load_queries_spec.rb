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
  let(:config) { double(InfluxdbSetup::Config, logger: logger) }

  subject { described_class.new(config) }

  context "no influxdb_queries.yml file present" do
    it "logs that it is skipping the continuous query setup" do
      subject.call

      expect(log).
        to eq(["[InfluxdbSetup] No influxdb_queries.yml file found, skipping continuous queries setup"])
    end
  end
end
