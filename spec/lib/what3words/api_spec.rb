# encoding: utf-8

require "spec_helper"

describe What3Words::API do

  let(:api_key) do
    path = File.expand_path("./.api_key")
    if ! File.file? path
      raise "Add your what3words API key to the '.api_key' file in the root of the project"
    end
    File.read(path).strip
  end

  let(:w3w) { described_class.new(:key => api_key) }

  it "returns errors from API" do
    badw3w = described_class.new(:key => "")
    expect { badw3w.words_to_position ["prom", "cape", "pump"] }.
      to raise_error described_class::ResponseError
  end

  describe "getting position from 3 words" do

    it "works with just 3 words" do
      result = w3w.words_to_position ["prom", "cape", "pump"]
      expect(result).to eq [51.484463, -0.195405]
    end

    it "gets full response from API" do
      result = w3w.words_to_position ["prom", "cape", "pump"], :full_response => true
      expect(result).to eq( :type => "3 words", :words => ["prom", "cape", "pump"],
       :position => [51.484463, -0.195405], :language => "en" )
    end

    it "works with string of 3 words separated by '.'" do
      result = w3w.words_to_position "prom.cape.pump"
      expect(result).to eq [51.484463, -0.195405]
    end

    it "sends all possible parameters" do
      result = w3w.words_to_position ["prom", "cape", "pump"], :full_response => true,
        :language => "fr"
      expect(result).to eq( :type => "3 words", :words => ["concevoir", "époque", "amasser"],
       :position => [51.484463, -0.195405], :language => "fr" )
    end

    it "checks word format matches standard regex" do
      expect { w3w.words_to_position ["1", "cape", "pump"] }.
        to raise_error described_class::WordError
    end
  end

  describe "getting position from OneWord" do
    it "works with basic parameters"

    it "gets full response from API"

    it "sends in all possible parameters"

    it "checks word format matches standard regex"
  end

  describe "gets 3 words" do
    it "from position"
  end
end
