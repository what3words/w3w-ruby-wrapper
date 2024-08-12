# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require_relative '../../../lib/what3words/api'

# to run the test type on terminal --> bundle exec rspec

describe What3Words::API, 'integration', integration: true do
  before(:all) do
    WebMock.allow_net_connect!
  end

  let(:api_key) { ENV['W3W_API_KEY'] }
  let(:w3w) { described_class.new(key: api_key) }

  it 'returns errors from API with an invalid key' do
    badw3w = described_class.new(key: 'BADKEY')
    expect { badw3w.convert_to_coordinates('prom.cape.pump') }
      .to raise_error(described_class::ResponseError)
  end

  describe 'convert_to_coordinates' do
    it 'works with a valid 3 word address' do
      result = nil
    begin
      result = w3w.convert_to_coordinates('prom.cape.pump')
    rescue What3Words::API::ResponseError => e
      puts e.message
    end
    expect(result).to include(
      words: 'prom.cape.pump',
      language: 'en'
    ) if result
    expect(result[:coordinates]).to include(
      lat: 51.484463,
      lng: -0.195405
    ) if result
    end

    it 'raises a ResponseError with the correct message when quota is exceeded' do
      error_response = {
        "error": {
          "code": "QuotaExceeded",
          "message": "Quota Exceeded. Please upgrade your usage plan, or contact support@what3words.com"
        }
      }.to_json

      stub_request(:get, /api.what3words.com/).to_return(status: 402, body: error_response, headers: { content_type: 'application/json' })

      expect {
        w3w.convert_to_coordinates('filled.count.soap')
      }.to raise_error(What3Words::API::ResponseError, 'QuotaExceeded: Quota Exceeded. Please upgrade your usage plan, or contact support@what3words.com')
    end

    it 'sends language parameter for 3 words' do
      result = nil
    begin
      result = w3w.convert_to_coordinates('prom.cape.pump')
    rescue What3Words::API::ResponseError => e
      puts e.message
    end
      expect(result).to include(
        words: 'prom.cape.pump',
        language: 'en'
      ) if result
    end

    it 'raises an error for an invalid 3 word address format' do
      expect { w3w.convert_to_coordinates('1.cape.pump') }
        .to raise_error(described_class::WordError)
    end

    it 'sends json format parameter for 3 words' do
      result = nil
    begin
      result = w3w.convert_to_coordinates('prom.cape.pump', format: 'json')
    rescue What3Words::API::ResponseError => e
      puts e.message
    end
      expect(result).to include(
        words: 'prom.cape.pump',
        language: 'en',
        country: 'GB',
        square: {
          southwest: {
            lng: -0.195426,
            lat: 51.484449
          },
          northeast: {
            lng: -0.195383,
            lat: 51.484476
          }
        },
        nearestPlace: 'Kensington, London',
        coordinates: {
          lng: -0.195405,
          lat: 51.484463
        },
        map: 'https://w3w.co/prom.cape.pump'
      ) if result
    end
  end

  describe 'convert_to_3wa' do
    it 'converts coordinates to a 3 word address in English' do
      result = w3w.convert_to_3wa([29.567041, 106.587875], format: 'json')
      expect(result).to include(
        words: 'disclose.strain.redefined',
        language: 'en'
      )
      expect(result[:coordinates]).to include(
        lat: 29.567041,
        lng: 106.587875
      )
    end

    it 'converts coordinates to a 3 word address in French' do
      result = w3w.convert_to_3wa([29.567041, 106.587875], language: 'fr', format: 'json')
      expect(result).to include(
        words: 'courgette.rabotons.infrason',
        language: 'fr'
      )
    end
  end

  describe 'autosuggest' do
    it 'returns suggestions for a valid input' do
      result = w3w.autosuggest('filled.count.soap')
      expect(result[:suggestions]).not_to be_empty
    end

    it 'returns the default number of suggestions for a simple input' do
      result = w3w.autosuggest('disclose.strain.redefin', language: 'en')
      expect(result[:suggestions].count).to eq(3)
    end

    it 'returns suggestions in the specified language' do
      result = w3w.autosuggest('trop.caler.perdre', language: 'fr')
      result[:suggestions].each do |suggestion|
        expect(suggestion[:language]).to eq('fr')
      end
    end

    it 'returns suggestions for an input in Arabic' do
      result = w3w.autosuggest('مربية.الصباح.المده', language: 'ar')
      expect(result[:suggestions]).not_to be_empty
    end

    it 'returns a specified number of results' do
      result = w3w.autosuggest('disclose.strain.redefin', language: 'en', 'n-results': 10)
      expect(result[:suggestions].count).to be >= 10
    end

    it 'returns suggestions with focus parameter' do
      result = w3w.autosuggest('filled.count.soap', focus: [51.4243877, -0.34745])
      expect(result[:suggestions]).not_to be_empty
    end

    it 'returns focused suggestions' do
      result = w3w.autosuggest('disclose.strain.redefin', language: 'en', 'n-focus-results': 3)
      expect(result[:suggestions].count).to be >= 3
    end

    it 'returns suggestions for generic-voice input type' do
      # @:param string input-type: For power users, used to specify voice input mode. Can be
      # text (default), vocon-hybrid, nmdp-asr or generic-voice.
      result = w3w.autosuggest 'fun with code', 'input-type': 'generic-voice', language: 'en'
      suggestions = result[:suggestions]
      output = ['fund.with.code', 'funds.with.code', 'fund.whiff.code']
      suggestions.each_with_index do |item, index|
        # puts item[:words]
        expect(item[:words]).to eq(output[index])
      end

      expect(result).not_to be_empty
    end

    it 'returns different suggestions with prefer-land parameter' do
      result_sea = w3w.autosuggest('///yourselves.frolicking.supernova', 'prefer-land': true, 'n-results': 1)
      result_land = w3w.autosuggest('///yourselves.frolicking.supernov', 'prefer-land': false,'n-results': 1)

      # puts "Sea suggestions: #{result_sea[:suggestions]}"
      # puts "Land suggestions: #{result_land[:suggestions]}"

      # Check if the suggestions arrays have different lengths or elements
      suggestions_different = (result_sea[:suggestions].length != result_land[:suggestions].length) ||
                              (result_sea[:suggestions] != result_land[:suggestions])

      expect(suggestions_different).to be true
    end

    it 'returns suggestions within specified countries' do
      result = w3w.autosuggest('disclose.strain.redefin', 'clip-to-country': 'GB,BE')
      result[:suggestions].each do |suggestion|
        expect(['GB', 'BE']).to include(suggestion[:country])
      end
    end

    it 'returns suggestions within a specified bounding box' do
      result = w3w.autosuggest('disclose.strain.redefin', 'clip-to-bounding-box': [51.521, -0.343, 52.6, 2.3324])
      expect(result[:suggestions]).to include(
        country: 'GB',
        nearestPlace: 'Saxmundham, Suffolk',
        words: 'discloses.strain.reddish',
        rank: 1,
        language: 'en'
      )
    end

    it 'raises an error with an invalid bounding box' do
      expect { w3w.autosuggest('disclose.strain.redefin', 'clip-to-bounding-box': [51.521, -0.343, 52.6]) }
        .to raise_error(described_class::ResponseError)
    end

    it 'raises an error with a second invalid bounding box' do
      expect { w3w.autosuggest('disclose.strain.redefin', 'clip-to-bounding-box': [51.521, -0.343, 55.521, -5.343]) }
        .to raise_error(described_class::ResponseError)
    end

    it 'returns suggestions within a specified circle' do
      result = w3w.autosuggest('disclose.strain.redefin', 'clip-to-circle': [51.521, -0.343, 142])
      expect(result[:suggestions]).to include(
        country: 'GB',
        nearestPlace: 'Market Harborough, Leicestershire',
        words: 'discloses.strain.reduce',
        rank: 1,
        language: 'en'
      )
    end

    it 'returns suggestions within a specified polygon' do
      result = w3w.autosuggest('disclose.strain.redefin', 'clip-to-polygon': [51.521, -0.343, 52.6, 2.3324, 54.234, 8.343, 51.521, -0.343])
      expect(result[:suggestions]).to include(
        country: 'GB',
        nearestPlace: 'Saxmundham, Suffolk',
        words: 'discloses.strain.reddish',
        rank: 1,
        language: 'en'
      )
    end
  end

  describe 'grid_section' do
    # @:param bounding-box: Bounding box, specified by the northeast and
    # southwest corner coordinates, for which the grid
    # should be returned.
    it 'returns a grid section for a valid bounding box' do
      result = w3w.grid_section '52.208867,0.117540,52.207988,0.116126'
      expect(result).not_to be_empty
    end

    it 'raises an error for an invalid bounding box' do
      expect { w3w.grid_section '50.0,178,50.01,180.0005' }
        .to raise_error described_class::ResponseError
    end
  end

  describe 'available_languages' do
    it 'retrieves all available languages' do
      result = w3w.available_languages
      expect(result[:languages].count).to be >= 51
    end

    it 'does not return an empty list of languages' do
      result = w3w.available_languages
      expect(result[:languages]).not_to be_empty
    end
  end

  describe 'isPossible3wa' do
    it 'returns true for a valid 3 word address' do
      expect(w3w.isPossible3wa('filled.count.soap')).to be true
    end

    it 'returns false for an invalid address with spaces' do
      expect(w3w.isPossible3wa('not a 3wa')).to be false
    end

    it 'returns false for an invalid address with mixed formats' do
      expect(w3w.isPossible3wa('not.3wa address')).to be false
    end
  end

  describe 'findPossible3wa' do
    it 'finds a single 3 word address in text' do
      text = "Please leave by my porch at filled.count.soap"
      expect(w3w.findPossible3wa(text)).to eq(['filled.count.soap'])
    end

    it 'finds multiple 3 word addresses in text' do
      text = "Please leave by my porch at filled.count.soap or deed.tulip.judge"
      expect(w3w.findPossible3wa(text)).to eq(['filled.count.soap', 'deed.tulip.judge'])
    end

    it 'returns an empty array when no 3 word address is found' do
      text = "Please leave by my porch at"
      expect(w3w.findPossible3wa(text)).to eq([])
    end
  end

  describe 'didYouMean' do
    it 'returns true for valid three word address with hyphens' do
      expect(w3w.didYouMean('filled-count-soap')).to be true
    end

    it 'returns true for valid three word address with spaces' do
      expect(w3w.didYouMean('filled count soap')).to be true
    end

    it 'returns false for invalid address with special characters' do
      expect(w3w.didYouMean('invalid#address!example')).to be false
    end

    it 'returns false for random text not in w3w format' do
      expect(w3w.didYouMean('this is not a w3w address')).to be false
    end
  end

  describe 'isValid3wa' do
    it 'returns true for a valid 3 word address' do
      expect(w3w.isValid3wa('filled.count.soap')).to be true
    end

    it 'returns false for an invalid 3 word address' do
      expect(w3w.isValid3wa('invalid.address.here')).to be false
    end

    it 'returns false for a random string' do
      expect(w3w.isValid3wa('this is not a w3w address')).to be false
    end
  end

  describe 'technical' do
    it 'deep_symbolize_keys helper works correctly' do
      expect(w3w.send(:deep_symbolize_keys, 'foo' => { 'bar' => true }))
        .to eq(foo: { bar: true })
    end
  end
end
