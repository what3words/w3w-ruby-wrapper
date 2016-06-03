# encoding: utf-8

require "spec_helper"

describe What3Words::API do

  before(:all) do
    WebMock.disable_net_connect!
  end

  let(:api_key) { "APIkey" }

  let(:w3w) { described_class.new(:key => api_key) }

  # it "returns errors from API" do
  #   stub_request(:get, "https://api.what3words.com/v2/forward").
  #     to_return(:status => 200, :body => '{"code": "300", "message": "Invalid or non-existent 3 word address"}')
  #
  #   expect { w3w.forward "a.b.c" }.
  #     to raise_error described_class::ResponseError
  # end

  describe "getting position" do

    # def stub!(query_params, response_body = {})
    #   stub_request(:get, "https://api.what3words.com/v2/forward").
    #     with(:query => query_params).
    #     to_return(:status => 200, :body => response_body.to_json)
    # end

    # it "sends 3 words given as string" do
    #     # stub_request(:get, "https://api.what3words.com/v2/forward?addr=a.b.c&key=APIkey").
    #     #     with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
    #     #     to_return(:status => 200, :body => '{"words" :"a.b.c"}', :headers => {})
    #     stub_request(:get, "https://api.what3words.com/v2/forward" ).
    #         # with(query: hash_including({"addr" => "a.b.c"}, {"key" => :api_key})).
    #         with(query: hash_including(:add => "abc", :key => :api_key)).
    #         to_return(:status => 200, :body => '{"words" :"a.b.c"}')
    # # stub! hash_including(:addr => "a.b.c")
    #   result = w3w.forward "a.b.c"
    #   puts result
    # end

    # it "extracts position from response" do
    #   stub!(hash_including(:addr => "prom.cape.pump"), {"position" => [1, 2]})
    #   result = w3w.forward "prom.cape.pump"
    #   expect(result).to eq [1, 2]
    # end

    # it "returns full response instead of just coords" do
    #   stub!(hash_including(:addr => "prom.cape.pump"),
    #     {"thanks" => "Thanks from all of us at index.home.raft for using a what3words API"})
    #   result = w3w.forward "prom.cape.pump", :full_response => true
    #   expect(result).to eq :thanks => "Thanks from all of us at index.home.raft for using a what3words API"
    # end

    # it "sends lang option" do
    #   stub!(hash_including(:addr => "prom.cape.pump", :lang => "fr"))
    #   w3w.forward "prom.cape.pump", :language => "fr"
    # end

    # it "parses response errors" do
    #   stub! hash_including(:addr => "prom.cape.pump"), {:error => "xx", :message => "msg"}
    #   expect { w3w.forward "prom.cape.pump" }.
    #     to raise_error described_class::ResponseError, "xx: msg"
    # end

    # it "checks 3 words as string matches standard regex" do
    #   stub! anything
    #   expect { w3w.words_to_position "1.cape.pump" }.
    #     to raise_error described_class::WordError
    # end

  end

  # describe "gets 3 words" do
  #
  #   def stub!(request_body, response_body = {})
  #     stub_request(:get, "https://api.what3words.com/v2/reverse").
  #       with(:body => request_body).
  #       to_return(:status => 200, :body => response_body.to_json)
  #   end
  #
  #   it "extracts 3 words from response" do
  #     stub! hash_including(:position => "1,2"), {:words => "prom.cape.pump"}
  #     expect(w3w.reverse([1, 2])).to eq "prom.cape.pump"
  #   end
  #
  #   it "sends lang option" do
  #     stub!(hash_including(:position => "1,2", :lang => "fr"))
  #     w3w.position_to_words([1, 2], :language => "fr")
  #   end
  #
  # end
  #
  # describe "getting available languages" do
  #
  #   def stub!(request_body, response_body = {})
  #     stub_request(:get, "http://api.what3words.com/get-languages").
  #       with(:body => request_body).
  #       to_return(:status => 200, :body => response_body.to_json)
  #   end
  #
  #   it "gets list of codes" do
  #     stub! anything, {:languages => [{:code => "l1"}, {:code => "l2"}]}
  #     expect(w3w.languages). to eq ["l1", "l2"]
  #   end
  #
  #   it "gets full response" do
  #     stub! anything, {:languages => [{:code => "l1"}, {:code => "l2"}]}
  #     expect(w3w.languages :full_response => true).
  #       to eq(:languages => [{:code => "l1"}, {:code => "l2"}])
  #   end
  # end

  it "'s deep_symbolize_keys helper works" do
    expect(w3w.deep_symbolize_keys("foo" => {"bar" => 1, "baz" => [{"quux" => "www"}]})).
      to eq(:foo => {:bar => 1, :baz => [{:quux => "www"}]})
  end
end
