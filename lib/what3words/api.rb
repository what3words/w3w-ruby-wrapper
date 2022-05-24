# encoding: utf-8

require 'rest-client'
require File.expand_path('../version', __FILE__)
require 'what3words/version'

module What3Words
  # Document the responsibility of the class
  #
  class API # rubocop:disable Metrics/ClassLength
    class Error < RuntimeError; end
    class ResponseError < Error; end
    class WordError < Error; end

    REGEX_3_WORD_ADDRESS = /^\p{L}+\.\p{L}+\.\p{L}+$/u
    REGEX_STRICT = /^\p{L}{3,}+\.\p{L}{3,}+\.\p{L}{3,}+$/u

    BASE_URL = 'https://api.what3words.com/v3/'.freeze

    ENDPOINTS = {
      convert_to_coordinates: 'convert-to-coordinates',
      convert_to_3wa: 'convert-to-3wa',
      available_languages: 'available-languages',
      autosuggest: 'autosuggest',
      grid_section: 'grid-section'
    }.freeze

    WRAPPER_VERSION = What3Words::VERSION

    def initialize(params)
      @key = params.fetch(:key)
    end

    attr_reader :key

    def convert_to_coordinates(words, params = {})
      words_string = get_words_string words
      request_params = assemble_convert_to_coordinates_request_params(words_string, params)
      puts 'c2c'
      puts request_params.inspect
      response = request! :convert_to_coordinates, request_params
      response
    end

    def convert_to_3wa(position, params = {})
      request_params = assemble_convert_to_3wa_request_params(position, params)
      response = request! :convert_to_3wa, request_params
      response
    end

    def grid_section(bbox, params = {})
      request_params = assemble_grid_request_params(bbox, params)
      response = request! :grid_section, request_params
      response
    end

    def available_languages
      request_params = assemble_common_request_params({})
      response = request! :available_languages, request_params
      response
    end

    def autosuggest(input, params = {})
      request_params = assemble_autosuggest_request_params(input, params)
      response = request! :autosuggest, request_params
      response
    end

    def assemble_common_request_params(params)
      h = { key: key }
      h[:language] = params[:language] if params[:language]
      h[:format] = params[:format] if params[:format]
      h
    end
    private :assemble_common_request_params

    def assemble_convert_to_coordinates_request_params(words_string, params)
      h = { words: words_string }
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_convert_to_coordinates_request_params

    def assemble_convert_to_3wa_request_params(position, params)
      h = { coordinates: position.join(',') }
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_convert_to_3wa_request_params

    def assemble_grid_request_params(bbox, params)
      h = { 'bounding-box': bbox }
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_grid_request_params

    def assemble_autosuggest_request_params(input, params)
      h = { input: input }
      h[:'n-results'] = params[:'n-results'].to_i if params[:'n-results']
      h[:focus] = params[:focus].join(',') if params[:focus].respond_to? :join 
      h[:'n-focus-results'] = params[:'n-focus-results'].to_i if params[:'n-focus-results']
      # h[:'clip-to-country'] = clip_to_country if clip_to_country.respond_to? :to_str
      # h[:'clip-to-bounding-box'] = clip_to_bounding_box if clip_to_bounding_box.respond_to? :to_str
      # h[:'clip-to-circle'] = clip_to_circle if clip_to_circle.respond_to? :to_str
      # h[:'clip-to-polygon'] = clip_to_polygon if clip_to_polygon.respond_to? :to_str
      # h[:'input-type'] = input_type
      # h[:'prefer-land'] = prefer_land
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_autosuggest_request_params

    def request!(endpoint_name, params)
      puts '----request---'
      puts endpoint(endpoint_name).inspect
      puts params.inspect

      # ADD HEADERS - THIS IS A PYTHON EXAMPLE headers = {'X-W3W-Wrapper': 'what3words-Ruby/{} (Ruby {}; {})'.format(__version__, platform.python_version(), platform.platform())}
      begin
        response = RestClient.get endpoint(endpoint_name), params: params
      rescue => e
        puts 'x03'
        puts e.inspect
        # puts e.methods.sort
        response = e.response
      end
      # puts '#{response.to_str}'
      # puts 'Response status: #{response.code}'
      
      response = JSON.parse(response.body)
      puts 'x04'
      puts response.inspect

      if response['error'].to_s.strip != ''
        raise ResponseError, "#{response['code']}: #{response['message']}"
      end
      deep_symbolize_keys(response)
    end
    private :request!

    def get_words_string(words)
      puts words.inspect
      if words.respond_to? :to_str
        w = words
      elsif words.respond_to? :join
        w = words.join('.')
      else
        raise Error, "Cannot get words string for #{words.inspect}"
      end
      check_words w
    end
    private :get_words_string

    def check_words(words)
      unless REGEX_3_WORD_ADDRESS.match(words)
        raise WordError, "#{words} is not a valid 3 word address"
      end
      words
    end
    private :check_words

    def deep_symbolize_keys(i)
      if i.is_a? Hash
        ni = {}
        # rubocop:disable Metrics/LineLength
        i.each { |k, v| ni[k.respond_to?(:to_sym) ? k.to_sym : k] = deep_symbolize_keys(v) }
        # rubocop:enable Metrics/LineLength
      elsif i.is_a? Array
        ni = i.map(&method(:deep_symbolize_keys))
      else
        ni = i
      end

      ni
    end

    def base_url
      BASE_URL
    end
    private :base_url

    def endpoint(name)
      base_url + ENDPOINTS.fetch(name)
    end
  end
end
