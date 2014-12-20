# encoding: utf-8

require "spec_helper"

describe What3Words::API do

  before(:all) do
    WebMock.disable_net_connect!
  end

  let(:api_key) { "APIkey" }

  let(:w3w) { described_class.new(:key => api_key) }

  it "returns errors from API" do
    stub_request(:post, "http://api.what3words.com/w3w").
      to_return(:status => 200, :body => '{"error": "XX", "message": "msg"}')

    expect { w3w.words_to_position ["prom", "cape", "pump"] }.
      to raise_error described_class::ResponseError
  end

  describe "getting position" do

    def stub!(request_body, response_body = {}, protocol = "http")
      r = stub_request(:post, "#{protocol}://api.what3words.com/w3w").
        with(:body => request_body).
        to_return(:status => 200, :body => response_body.to_json)
    end

    it "sends 3 words given as array" do
      stub! hash_including(:string => "a.b.c")
      result = w3w.words_to_position ["a", "b", "c"]
    end

    it "sends 3 words given as string" do
      stub! hash_including(:string => "a.b.c")
      result = w3w.words_to_position "a.b.c"
    end

    it "extracts position from response" do
      stub! hash_including(:string => "a.b.c"), {"position" => [1, 2]}
      result = w3w.words_to_position "a.b.c"
      expect(result).to eq [1, 2]
    end

    it "returns full response instead of just coords" do
      stub!(hash_including(:string => "a.b.c"),
        {"full" => true})
      result = w3w.words_to_position "a.b.c", :full_response => true
      expect(result).to eq :full => true
    end

    it "sends lang option" do
      stub!(hash_including(:string => "a.b.c", :lang => "fr"))
      w3w.words_to_position "a.b.c", :language => "fr"
    end

    it "sends corners option" do
      stub!(hash_including(:string => "a.b.c", :corners => "true"))
      w3w.words_to_position "a.b.c", :corners => true
    end

    it "uses https for private OneWord with oneword-password" do
      stub!(hash_including(:string => "a.b.c", :"oneword-password" => "oopw"),
        {}, "https")
      w3w.words_to_position "a.b.c", :oneword_password => "oopw"
    end

    it "uses https for private OneWord with email / password" do
      stub!(hash_including(:string => "a.b.c", :email => "em", :password => "pw"),
        {}, "https")
      w3w.words_to_position "a.b.c", :email => "em", :password => "pw"
    end

    it "parses response errors" do
      stub! hash_including(:string => "a.b.c"), {:error => "xx", :message => "msg"}
      expect { w3w.words_to_position "a.b.c" }.
        to raise_error described_class::ResponseError, "xx: msg"
    end

    it "checks 3 words as array matches standard regex" do
      stub! anything
      expect { w3w.words_to_position ["1", "cape", "pump"] }.
        to raise_error described_class::WordError
    end

    it "checks 3 words as string matches standard regex" do
      stub! anything
      expect { w3w.words_to_position "1.cape.pump" }.
        to raise_error described_class::WordError
    end

    it "checks OneWord format matches standard regex" do
      stub! anything
      expect { w3w.words_to_position "123foo" }.
        to raise_error described_class::WordError
    end
  end

  describe "gets 3 words" do

    def stub!(request_body, response_body = {})
      r = stub_request(:post, "http://api.what3words.com/position").
        with(:body => request_body).
        to_return(:status => 200, :body => response_body.to_json)
    end

    it "extracts 3 words from response" do
      stub! hash_including(:position => "1,2"), {:words => ["a", "b", "c"]}
      expect(w3w.position_to_words([1, 2])).to eq ["a", "b", "c"]
    end

    it "returns full response if asked" do
      stub! hash_including(:position => "1,2"), {:full => "1"}
      expect(w3w.position_to_words([1, 2], :full_response => true)).to eq(:full => "1")
    end

    it "sends lang option" do
      stub!(hash_including(:position => "1,2", :lang => "fr"))
      w3w.position_to_words([1, 2], :language => "fr")
    end

    it "sends corners option" do
      stub!(hash_including(:position => "1,2", :corners => "true"))
      w3w.position_to_words([1, 2], :corners => true)
    end

  end

  it "'s deep_symbolize_keys helper works" do
    expect(w3w.deep_symbolize_keys("foo" => {"bar" => true})).
      to eq(:foo => {:bar => true})
  end
end
