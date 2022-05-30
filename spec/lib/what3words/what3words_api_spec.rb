# encoding: utf-8

require 'spec_helper'

# to run the test type on terminal --> bundle exec rspec

# rubocop:disable Metrics/LineLength
describe What3Words::API, 'integration', integration: true do # rubocop:disable Metrics/BlockLength
  # rubocop:enable Metrics/LineLength
  before(:all) do
    WebMock.allow_net_connect!
  end

  let(:api_key) { ENV['W3W_API_KEY'] }
  
  let(:w3w) { described_class.new(key: api_key) }

  it 'returns errors from API' do
    badw3w = described_class.new(key: 'BADKEY')
    expect { badw3w.convert_to_coordinates 'prom.cape.pump' }
      .to raise_error described_class::ResponseError
  end

  describe 'getting position' do
    # @:param string words: A 3 word address as a string
    # @:param string format: Return data format type; can be one of json (the default), geojson
    it 'works with string of 3 words separated by \'.\'' do
      result = w3w.convert_to_coordinates 'prom.cape.pump'
      expect(result).to include(
        words: 'prom.cape.pump',
        language: 'en'
      )
      expect(result[:coordinates]).to include(
        lat: 51.484463,
        lng: -0.195405
      )
    end

    it 'sends language parameter for 3 words' do
      result = w3w.convert_to_coordinates 'prom.cape.pump'
      expect(result).to include(
        words: 'prom.cape.pump',
        language: 'en'
      )
    end

    it 'checks 3 words format matches standard regex' do
      expect { w3w.convert_to_coordinates '1.cape.pump' }
        .to raise_error described_class::WordError
    end

    it 'sends json parameter for 3 words' do
      result = w3w.convert_to_coordinates 'prom.cape.pump', format: 'json'
      expect(result).to include(
        words: 'prom.cape.pump',
        language: 'en',
        country: 'GB',
        square: {
          'southwest': {
            'lng': -0.195426,
            'lat': 51.484449
          },
          'northeast': {
            'lng': -0.195383,
            'lat': 51.484476
          }
        },
        nearestPlace: 'Kensington, London',
          'coordinates': {
            'lng': -0.195405,
            'lat': 51.484463
          },
        map: 'https://w3w.co/prom.cape.pump'
      )
    end
  end

  describe 'gets 3 words' do
    # @:param coordinates: the coordinates of the location to convert to 3 word address
    it 'from position' do
      result = w3w.convert_to_3wa [29.567041, 106.587875], format: 'json'
      expect(result).to include(
        words: 'disclose.strain.redefined',
        language: 'en'
      )
      expect(result[:coordinates]).to include(
        lat: 29.567041,
        lng: 106.587875
      )
    end

    it 'from position in fr' do
      result = w3w.convert_to_3wa [29.567041, 106.587875], language: 'fr', format: 'json'
      expect(result).to include(
        words: 'courgette.rabotons.infrason',
        language: 'fr'
      )
    end
  end

  describe 'autosuggest' do
    it 'single input returns suggestions' do
      # @:param string input: The full or partial 3 word address to obtain
      # suggestions for. At minimum this must be the
      # first two complete words plus at least one
      # character from the third word
      result = w3w.autosuggest 'disclose.strain.redefin'
      expect(result).not_to be_empty
    end

    it 'simple input will return 3 suggestions' do
      # @:param string input: The full or partial 3 word address to obtain
      # suggestions for. At minimum this must be the
      # first two complete words plus at least one
      # character from the third word
      result = w3w.autosuggest 'disclose.strain.redefin', language: 'en'
      n_default_results = result[:suggestions].count
      expect(n_default_results).to eq(3)
    end

    it 'sends language parameter to an input in a different language' do
      # @:param string language: A supported 3 word address language as an
      # ISO 639-1 2 letter code.
      result = w3w.autosuggest 'trop.caler.perdre', language: 'fr'
      language = result[:suggestions]
      language.each do |k|
        k.each do |k,v|
          if k == 'language'
            expect(v).to eq('fr')
          end
        end
      end
    end

    it 'sends arabic language as a different input' do
      
      result = w3w.autosuggest 'مربية.الصباح.المده', language: 'ar'
      expect(result).not_to be_empty
    end

    it 'with n-results' do
      # @:param int n_results: The number of AutoSuggest results to return. A maximum of 100 
      # results can be specified, if a number greater than this is 
      # requested, this will be truncated to the maximum. The default is 3
      result = w3w.autosuggest 'disclose.strain.redefin', language: 'en', 'n-results': 10
      # puts result[:suggestions].count
      n_results = result[:suggestions].count
      expect(n_results).to be >= 10
    end

    it 'with n-focus-results' do
      # @:param int n_focus_results: Specifies the number of results (must be <= n_results) 
      # within the results set which will have a focus. Defaults to 
      # n_results. This allows you to run autosuggest with a mix of 
      # focussed and unfocussed results, to give you a "blend" of the two.
      result = w3w.autosuggest 'disclose.strain.redefin', language: 'en', 'n-focus-results': 10
      # puts result[:suggestions].count
      n_focus_results = result[:suggestions].count
      expect(n_focus_results).to be >= 3
    end

    it 'with input-type' do
      # @:param string input_type: For power users, used to specify voice input mode. Can be 
      # text (default), vocon-hybrid, nmdp-asr or generic-voice.
      result = w3w.autosuggest 'disclose.strain.redefin', 'input-type': 'text'
      expect(result).not_to be_empty
    end

    xit 'with prefer-land' do
      # @:param string prefer_land: Makes autosuggest prefer results on land to those in the sea. 
      # This setting is on by default. Use false to disable this setting and 
      # receive more suggestions in the sea.
      result_sea = w3w.autosuggest 'disclose.strain.redefin', 'prefer-land': false, 'n-results': 10
      result_sea_suggestions = result_sea[:suggestions]

      result_land = w3w.autosuggest 'disclose.strain.redefin', 'prefer-land': true, 'n-results': 10
      result_land_suggestions = result_land[:suggestions]

      expect(result_sea_suggestions).not_to eq(result_land_suggestions)
    end

    it 'with clip_to_country' do
      # @:param string clip-to-country: Restricts autosuggest to only return results inside the 
      # countries specified by comma-separated list of uppercase ISO 3166-1 
      # alpha-2 country codes (for example, to restrict to Belgium and the 
      # UK, use clip_to_country="GB,BE")
      result = w3w.autosuggest 'disclose.strain.redefin', 'clip-to-country': 'GB,BE'
      country = result[:suggestions]
      country.each do |item|
        item.each do |k,v|
          if k == 'country' 
            if v == 'GB'
              expect(v).to eq('GB')
            else
              expect(v).to eq('BE')
            end
          end
        end
      end
    end

    it 'with clip-to-bounding-box' do
      # @:param clip-to-bounding-box: Restrict autosuggest results to a bounding 
      # box, specified by coordinates.
      result = w3w.autosuggest 'disclose.strain.redefin','clip-to-bounding-box': [51.521,-0.343,52.6,2.3324]
      suggestions = result[:suggestions]
      expect(suggestions).to include(
        country: "GB",
        nearestPlace: "Saxmundham, Suffolk",
        words: "discloses.strain.reddish",
        rank: 1,
        language: "en",
      )
    end

    it 'with clip-to-bounding-box raise BadClipToBoundingBox error with 3 coordinates' do
      # @:param clip-to-bounding-box: Restrict autosuggest results to a bounding 
      # box, specified by coordinates.
      expect { w3w.autosuggest 'disclose.strain.redefin','clip-to-bounding-box': [51.521,-0.343,52.6] }
        .to raise_error described_class::ResponseError
        # {"error"=>{"code"=>"BadClipToBoundingBox", "message"=>"Must be four lat,lng,lat,lng coordinates such as 50,-2,53.12,2.34"}}
    end

    it 'with clip-to-bounding-box raise 2nd BadClipToBoundingBox error' do
      # @:param clip-to-bounding-box: Restrict autosuggest results to a bounding 
      # box, specified by coordinates.
      expect { w3w.autosuggest 'disclose.strain.redefin','clip-to-bounding-box': [51.521,-0.343,55.521,-5.343] }
        .to raise_error described_class::ResponseError
        # {"error"=>{"code"=>"BadClipToBoundingBox", "message"=>"First lng must be <= second lng. South,west,north,east expected."}}    end
    end

    it 'with clip-to-circle' do
      # @:param clip-to-circle: Restrict autosuggest results to a circle, specified by
      # the center of the circle, latitude and longitude, and a distance in 
      # kilometres which represents the radius. For convenience, longitude 
      # is allowed to wrap around 180 degrees. For example 181 is equivalent 
      # to -179.
      result = w3w.autosuggest 'disclose.strain.redefin','clip-to-circle': [51.521,-0.343,142]
      suggestions = result[:suggestions]
      expect(suggestions).to include(
        country: "GB",
        nearestPlace: "Market Harborough, Leicestershire",
        words: "discloses.strain.reduce",
        rank: 1,
        language: "en",
      )
    end

    it 'with clip-to-polygon' do
      # @:param clip-to-polygon: Restrict autosuggest results to a polygon, 
      # specified by a list of coordinates. The polygon 
      # should be closed, i.e. the first element should be repeated as the 
      # last element; also the list should contain at least 4 entries. 
      # The API is currently limited to accepting up to 25 pairs.
      result = w3w.autosuggest 'disclose.strain.redefin','clip-to-polygon': [51.521,-0.343,52.6,2.3324,54.234,8.343,51.521,-0.343]
      suggestions = result[:suggestions]
      expect(suggestions).to include(
        country: "GB",
        nearestPlace: "Saxmundham, Suffolk",
        words: "discloses.strain.reddish",
        rank: 1,
        language: "en",
      )
    end
  end

  describe 'grid_section' do
    # @:param bounding-box: Bounding box, specified by the northeast and
    # southwest corner coordinates, for which the grid
    # should be returned.
    it 'string input not empty' do
      result = w3w.grid_section '52.208867,0.117540,52.207988,0.116126'
      expect(result).not_to be_empty
    end
    it 'bad bounding box error if the bbox is greater 4km' do
      expect{ w3w.grid_section '50.0,178,50.01,180.0005'}
        .to raise_error described_class::ResponseError
    end
  end

  describe 'available_languages' do
    it 'gets all available languages' do
      result = w3w.available_languages
      all_languages = result[:languages].count
      expect(all_languages).to be >= 51
    end
    it 'it does not return an empty list' do
      result = w3w.available_languages
      expect(result).not_to be_empty
    end
  end 

  describe 'technical' do
    it '\'s deep_symbolize_keys helper works' do
      expect(w3w.deep_symbolize_keys('foo' => { 'bar' => true }))
        .to eq(foo: { bar: true })
    end
  end

end
