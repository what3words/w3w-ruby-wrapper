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

  # it 'returns errors from API' do
  #   badw3w = described_class.new(key: 'BADKEY')
  #   expect { badw3w.convert_to_coordinates 'prom.cape.pump' }
  #     .to raise_error described_class::ResponseError
  # end

  # describe 'getting position' do
  #   it 'works with string of 3 words separated by \'.\'' do
  #     result = w3w.convert_to_coordinates 'prom.cape.pump'
  #     expect(result).to include(
  #       words: 'prom.cape.pump',
  #       language: 'en'
  #     )
  #     expect(result[:coordinates]).to include(
  #       lat: 51.484463,
  #       lng: -0.195405
  #     )
  #   end

  #   it 'sends language parameter for 3 words' do
  #     result = w3w.convert_to_coordinates 'prom.cape.pump'
  #     expect(result).to include(
  #       words: 'prom.cape.pump',
  #       language: 'en'
  #     )
  #   end

  #   it 'checks 3 words format matches standard regex' do
  #     expect { w3w.convert_to_coordinates '1.cape.pump' }
  #       .to raise_error described_class::WordError
  #   end

  #   it 'sends json parameter for 3 words' do
  #     result = w3w.convert_to_coordinates 'prom.cape.pump', format: 'json'
  #     expect(result).to include(
  #       words: 'prom.cape.pump',
  #       language: 'en',
  #       country: 'GB',
  #       square: {
  #         'southwest': {
  #           'lng': -0.195426,
  #           'lat': 51.484449
  #         },
  #         'northeast': {
  #           'lng': -0.195383,
  #           'lat': 51.484476
  #         }
  #       },
  #       nearestPlace: 'Kensington, London',
  #         'coordinates': {
  #           'lng': -0.195405,
  #           'lat': 51.484463
  #         },
  #       map: 'https://w3w.co/prom.cape.pump'
  #     )
  #   end
  # end

  # describe 'gets 3 words' do
  #   it 'from position' do
  #     result = w3w.convert_to_3wa [29.567041, 106.587875], format: 'json'
  #     expect(result).to include(
  #       words: 'disclose.strain.redefined',
  #       language: 'en'
  #     )
  #   end

  #   it 'from position in fr' do
  #     result = w3w.convert_to_3wa [29.567041, 106.587875], language: 'fr', format: 'json'
  #     expect(result).to include(
  #       words: 'courgette.rabotons.infrason',
  #       language: 'fr'
  #     )
  #   end
  # end

  describe 'autosuggest' do
    it 'single input returns suggestions' do
      result = w3w.autosuggest 'disclose.strain.redefin'
      expect(result).not_to be_empty
    end

    it 'simple input will return 3 suggestions' do
      result = w3w.autosuggest 'disclose.strain.redefin', language: 'en'
      n_default_results = result[:suggestions].count
      expect(n_default_results).to eq(3)
    end

    it 'sends language parameter to an input in a different language' do
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

    it 'with n-results' do
      result = w3w.autosuggest 'disclose.strain.redefin', language: 'en', 'n-results': 10
      # puts result[:suggestions].count
      n_results = result[:suggestions].count
      expect(n_results).to be >= 10
    end

    it 'with focus' do
      # result =
      w3w.autosuggest 'disclose.strain.redefin', language: 'en', focus: [29.567041, 106.587875]
    end

    it 'with n-focus-results' do
      result = w3w.autosuggest 'disclose.strain.redefin', language: 'en', 'n-focus-results': 10
      # puts result[:suggestions].count
      n_focus_results = result[:suggestions].count
      expect(n_focus_results).to be >= 3
    end

    # it 'with clipping radius around focus' do
    #   # result =
    #   w3w.autosuggest 'disclose.strain.redefin', language: 'en', [29.567041, 106.587875],'focus(10)'
    # end

    # it 'arabic input' do
    #   # result =
    #   w3w.autosuggest 'مربية.الصباح.المده', 'ar'
    # end
  end

  # describe 'grid_section' do
  #   it 'string input not empty' do
  #     result = w3w.grid_section '52.208867,0.117540,52.207988,0.116126'
  #     expect(result).not_to be_empty
  #   end
  #   it 'bad bounding box error if the bbox is greater 4km' do
  #     expect{ w3w.grid_section '50.0,178,50.01,180.0005'}
  #       .to raise_error described_class::ResponseError
  #   end
  # end

  # describe 'available_languages' do
  #   it 'gets all available languages' do
  #     result = w3w.available_languages
  #     all_languages = result[:languages].count
  #     expect(all_languages).to be >= 51
  #   end
  #   it 'it does not return an empty list' do
  #     result = w3w.available_languages
  #     expect(result).not_to be_empty
  #   end
  # end 

  # describe 'technical' do
  #   it '\'s deep_symbolize_keys helper works' do
  #     expect(w3w.deep_symbolize_keys('foo' => { 'bar' => true }))
  #       .to eq(foo: { bar: true })
  #   end
  # end

end
