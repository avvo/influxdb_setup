require 'spec_helper'

describe InfluxdbSetup do
  it 'has a version number' do
    expect(InfluxdbSetup::VERSION).not_to be nil
  end
end
