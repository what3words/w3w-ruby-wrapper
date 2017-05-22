# encoding: utf-8

require 'spec_helper'
# rubocop:disable Metrics/LineLength
describe What3Words::API, 'integration', integration: true do # rubocop:disable Metrics/BlockLength
  # rubocop:enable Metrics/LineLength
  before(:all) do
    WebMock.allow_net_connect!
  end

  let(:api_key) { ENV['W3W_API_KEY'] }

  let(:w3w) { described_class.new(key: api_key) }

  it 'returns errors from API' do
    badw3w = described_class.new(key: '')
    expect { badw3w.forward %w(prom cape pump) }
      .to raise_error described_class::ResponseError
  end

  describe 'getting position' do
    it 'works with string of 3 words separated by \'.\'' do
      result = w3w.forward 'prom.cape.pump'
      expect(result).to include(
        words: 'prom.cape.pump',
        language: 'en'
      )
      expect(result[:geometry]).to include(
        lat: 51.484463,
        lng: -0.195405
      )
    end

    it 'sends lang parameter for 3 words' do
      result = w3w.forward %w(prom cape pump), lang: 'fr'
      expect(result).to include(
        words: 'concevoir.époque.amasser',
        language: 'fr'
      )
    end

    it 'checks 3 words format matches standard regex' do
      expect { w3w.forward '1.cape.pump' }
        .to raise_error described_class::WordError
    end
  end

  describe 'gets 3 words' do
    it 'from position' do
      result = w3w.reverse [29.567041, 106.587875]
      expect(result).to include(
        words: 'disclose.strain.redefined',
        language: 'en'
      )
    end

    it 'from position in fr' do
      result = w3w.reverse [29.567041, 106.587875], lang: 'fr'
      expect(result).to include(
        words: 'courgette.rabotons.infrason',
        language: 'fr'
      )
    end
  end
  describe 'autosuggest' do
    it 'simple addr' do
      # result =
      w3w.autosuggest 'trop.caler.perdre', 'fr'
    end

    it 'with focus' do
      # result =
      w3w.autosuggest 'disclose.strain.redefin', 'en', [29.567041, 106.587875]
    end

    it 'with clipping radius around focus' do
      # result =
      w3w.autosuggest 'disclose.strain.redefin', 'en', [29.567041, 106.587875],
                      'focus(10)'
    end

    it 'arabic addr' do
      # result =
      w3w.autosuggest 'مربية.الصباح.المده', 'ar'
    end
  end

  describe 'autosuggest-ml' do
    it '3 langs (result prefered de)' do
      # result =
      w3w.autosuggest_ml 'geschaft.planter.carciofi', 'de'
    end
    it '3 langs (result prefered fr)' do
      # result =
      w3w.autosuggest_ml 'geschaft.planter.carciofi', 'fr'
    end
    it '3 langs (result prefered it)' do
      # result =
      w3w.autosuggest_ml 'geschaft.planter.carciofi', 'it'
    end
  end

  describe 'standardblend' do
    it 'simple addr' do
      # result =
      w3w.standardblend 'trop.caler.perdre', 'fr'
    end

    it 'with focus' do
      # result =
      w3w.standardblend 'disclose.strain.redefin', 'en', [29.567041, 106.587875]
    end
  end

  describe 'standardblend-ml' do
    it '3 langs (result prefered de)' do
      # result =
      w3w.standardblend_ml 'geschaft.planter.carciofi', 'de'
    end
    it '3 langs (result prefered fr)' do
      # result =
      w3w.standardblend_ml 'geschaft.planter.carciofi', 'fr'
    end
    it '3 langs (result prefered it)' do
      # result =
      w3w.standardblend_ml 'geschaft.planter.carciofi', 'it'
    end
  end

  describe 'grid' do
    it 'string input' do
      # result =
      w3w.grid '52.208867,0.117540,52.207988,0.116126'
    end
  end

  describe 'languages' do
    it 'gets all languages' do
      # result =
      w3w.languages
    end
  end

  describe 'technical' do
    it '\'s deep_symbolize_keys helper works' do
      expect(w3w.deep_symbolize_keys('foo' => { 'bar' => true }))
        .to eq(foo: { bar: true })
    end
  end
end
