# encoding: utf-8

require "spec_helper"
require "yaml"

describe What3Words::API, "integration", :integration => true do

  before(:all) do
    WebMock.allow_net_connect!
  end

  let!(:config) do
    file = "spec/config.yaml"
    if ! File.exist? file
      raise "Add a file #{file} (use spec/config.sample.yaml as a template) with correct values to run integration specs"
    end
    YAML.load_file file
  end

  let(:api_key) { config["api_key"] }
  let(:private_one_word) { config["private_one_word"] }
  let(:private_one_word_password) { config["private_one_word_password"] }

  let(:w3w) { described_class.new(:key => api_key) }

  it "returns errors from API" do
    badw3w = described_class.new(:key => "")
    expect { badw3w.words_to_position ["prom", "cape", "pump"] }.
      to raise_error described_class::ResponseError
  end

  describe "getting position" do

    it "works with 3 words in array" do
      result = w3w.words_to_position ["prom", "cape", "pump"]
      expect(result).to eq [51.484463, -0.195405]
    end

    it "works with string of 3 words separated by '.'" do
      result = w3w.words_to_position "prom.cape.pump"
      expect(result).to eq [51.484463, -0.195405]
    end

    it "gets full response from API" do
      result = w3w.words_to_position ["prom", "cape", "pump"], :full_response => true
      expect(result).to eq( :type => "3 words", :words => ["prom", "cape", "pump"],
       :position => [51.484463, -0.195405], :language => "en" )
    end

    it "sends all possible parameters for 3 words" do
      result = w3w.words_to_position ["prom", "cape", "pump"], :full_response => true,
        :language => "fr", :corners => true
      expect(result).to eq(
        :type => "3 words", :words => ["concevoir", "époque", "amasser"],
        :position => [51.484463, -0.195405], :language => "fr",
        :corners => [[51.484449, -0.195426], [51.484476, -0.195383]])
    end

    it "checks 3 words format matches standard regex" do
      expect { w3w.words_to_position ["1", "cape", "pump"] }.
        to raise_error described_class::WordError

      expect { w3w.words_to_position "1.cape.pump" }.
        to raise_error described_class::WordError
    end

    it "checks OneWord format matches standard regex" do
      expect { w3w.words_to_position "123foo" }.
        to raise_error described_class::WordError
    end

    it "works with a OneWord" do
      result = w3w.words_to_position "*LibertyTech"
      expect(result).to eq [51.512573, -0.144879]
    end

    it "disallows access to protected OneWord" do
      expect { w3w.words_to_position private_one_word }.
        to raise_error described_class::ResponseError
    end

    it "accesses OneWord protected by oneword password" do
      expect(w3w.words_to_position private_one_word,
        :oneword_password => private_one_word_password).
        to eq [29.567043, 106.587865]
    end

    xit "accesses OneWord protected by user credentials (username & password)"
  end

  describe "gets 3 words" do
    it "from position" do
      expect(w3w.position_to_words [29.567041, 106.587875], :language => "fr").
        to eq ["courgette", "approbateur", "infrason"]
    end
  end

  it "gets languages" do
    expect(w3w.languages).to include "en"
  end

  it "'s deep_symbolize_keys helper works" do
    expect(w3w.deep_symbolize_keys("foo" => {"bar" => true})).
      to eq(:foo => {:bar => true})
  end
end
