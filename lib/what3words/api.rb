# frozen_string_literal: true

require 'rest-client'
require File.expand_path('../version', __FILE__)
require 'what3words/version'

module What3Words
  # What3Words v3 API wrapper
  class API # rubocop:disable Metrics/ClassLength
    # This class provides an interface to the what3words API
    # at https://developer.what3words.com/public-api/docs
    class Error < RuntimeError; end
    class ResponseError < Error; end
    class WordError < Error; end

    REGEX_3_WORD_ADDRESS = /^\p{L}+\.\p{L}+\.\p{L}+$/u.freeze
    REGEX_STRICT = /^\p{L}{3,}+\.\p{L}{3,}+\.\p{L}{3,}+$/u.freeze

    BASE_URL = 'https://api.what3words.com/v3/'

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
      # Take a 3 word address and turn it into a pair of coordinates.
      #   @:param string words: A 3 word address as a string
      #   @:param string format: Return data format type; can be one of json (the default), geojson
      # API Reference: https://docs.what3words.com/api/v3/#convert-to-coordinates
      words_string = get_words_string words
      request_params = assemble_convert_to_coordinates_request_params(words_string, params)
      response = request! :convert_to_coordinates, request_params
      response
    end

    def convert_to_3wa(position, params = {})
      # Take latitude and longitude coordinates and turn them into a 3 word address.
      #   @:param coordinates: the coordinates of the location to convert to 3 word address
      #   @:param string format: Return data format type; can be one of json (the default), geojson
      #   @:param string language: A supported 3 word address language as an ISO 639-1 2 letter code.
      # API Reference: https://docs.what3words.com/api/v3/#convert-to-3wa
      request_params = assemble_convert_to_3wa_request_params(position, params)
      response = request! :convert_to_3wa, request_params
      response
    end

    def grid_section(bbox, params = {})
      # Returns a section of the 3m x 3m what3words grid for a given area.
      #   @:param bounding-box: Bounding box, specified by the northeast and southwest corner coordinates,
      #     for which the grid should be returned.
      #   @:param string format: Return data format type; can be one of json (the default), geojson
      # API Reference: https://docs.what3words.com/api/v3/#grid-section
      request_params = assemble_grid_request_params(bbox, params)
      response = request! :grid_section, request_params
      response
    end

    def available_languages
      # Retrieve a list of available 3 word languages.
      # API Reference: https://docs.what3words.com/api/v3/#available-languages
      request_params = assemble_common_request_params({})
      response = request! :available_languages, request_params
      response
    end

    def autosuggest(input, params = {})
      # Returns a list of 3 word addresses based on user input and other parameters.
      #   @:param string input: The full or partial 3 word address to obtain suggestions for.
      #     At minimum this must be the first two complete words plus at least one character
      #     from the third word.
      #   @:param int n_results: The number of AutoSuggest results to return.
      #     A maximum of 100 results can be specified, if a number greater than this is requested,
      #     this will be truncated to the maximum. The default is 3.
      #   @:param focus: A location, specified as a latitude,longitude used
      #     to refine the results. If specified, the results will be weighted to give preference to those near
      #     the specified location in addition to considering similarity to the suggest string. If omitted the
      #     default behaviour is to weight results for similarity to the suggest string only.
      #   @:param int n_focus_results: Specifies the number of results (must be <= n_results)
      #     within the results set which will have a focus. Defaults to n_results.
      #     This allows you to run autosuggest with a mix of focussed and unfocussed results,
      #     to give you a "blend" of the two.
      #   @:param string clip-to-country: Restricts autosuggest to only return results inside
      #     the countries specified by comma-separated list of uppercase ISO 3166-1
      #     alpha-2 country codes (for example, to restrict to Belgium and the UK,
      #     use clip_to_country="GB,BE").
      #   @:param clip-to-bounding-box: Restrict autosuggest results to a bounding box, specified by coordinates.
      #   @:param clip-to-circle: Restrict autosuggest results to a circle, specified by
      #     the center of the circle, latitude and longitude, and a distance in kilometres which represents the radius.
      #     For convenience, longitude is allowed to wrap around 180 degrees. For example 181 is equivalent to -179.
      #   @:param clip-to-polygon: Restrict autosuggest results to a polygon, specified by a list of coordinates.
      #     The polygon should be closed, i.e. the first element should be repeated as the
      #     last element; also the list should contain at least 4 entries.
      #     The API is currently limited to accepting up to 25 pairs.
      #   @:param string input-type: For power users, used to specify voice input mode.
      #     Can be text (default), vocon-hybrid, nmdp-asr or generic-voice.
      #   @:param string prefer-land: Makes autosuggest prefer results on land to those in the sea.
      #   @:param string language: A supported 3 word address language as an ISO 639-1 2 letter code.
      #     This setting is on by default. Use false to disable this setting and receive more suggestions in the sea.

      # API Reference: https://docs.what3words.com/api/v3/#autosuggest
      request_params = assemble_autosuggest_request_params(input, params)
      response = request! :autosuggest, request_params
      response
    end

    def assemble_common_request_params(params)
      # Return common request params
      #   @:param api_key: A valid API key
      #   @:param string language: A supported 3 word address language as an ISO 639-1 2 letter code.
      #   @:param string format: Return data format type; can be one of json (the default), geojson
      h = { key: key }
      h[:language] = params[:language] if params[:language]
      h[:format] = params[:format] if params[:format]
      h
    end
    private :assemble_common_request_params

    def assemble_convert_to_coordinates_request_params(words_string, params)
      # Returns request params for the convert to coordinates function
      #   @:param string words: A 3 word address as a string
      h = { words: words_string }
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_convert_to_coordinates_request_params

    def assemble_convert_to_3wa_request_params(position, params)
      # Return request params for the convert to 3wa function
      #   @:param coordinates: the coordinates of the location to convert to 3 word address
      h = { coordinates: position.join(',') }
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_convert_to_3wa_request_params

    def assemble_grid_request_params(bbox, params)
      # Returns the request params for the grid_section function
      #   @:param bounding-box: Bounding box, specified by the northeast and
      #     southwest corner coordinates, for which the grid should be returned.
      h = { 'bounding-box': bbox }
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_grid_request_params

    def assemble_autosuggest_request_params(input, params)
      # Returns the request params for the autosuggest function
      #   @:param string input: The full or partial 3 word address to obtain suggestions for.
      #     At minimum this must be the first two complete words plus
      #     at least one character from the third word.
      #   @:param int n_results: The number of AutoSuggest results to return.
      #     A maximum of 100 results can be specified, if a number greater than this is requested,
      #     this will be truncated to the maximum. The default is 3.
      #   @:param focus: A location, specified as a latitude,longitude used
      #     to refine the results. If specified, the results will be weighted to give preference to those near
      #     the specified location in addition to considering similarity to the suggest string. If omitted the
      #     default behaviour is to weight results for similarity to the suggest string only.
      #   @:param int n_focus_results: Specifies the number of results (must be <= n_results)
      #     within the results set which will have a focus. Defaults to n_results.
      #     This allows you to run autosuggest with a mix of
      #     focussed and unfocussed results, to give you a "blend" of the two.
      #   @:param string clip-to-country: Restricts autosuggest to only return results inside
      #     the countries specified by comma-separated list of uppercase ISO 3166-1
      #     alpha-2 country codes (for example, to restrict to Belgium and the UK,
      #     use clip_to_country="GB,BE").
      #   @:param clip-to-bounding-box: Restrict autosuggest results to a bounding box, specified by coordinates.
      #   @:param clip-to-circle: Restrict autosuggest results to a circle, specified by
      #     the center of the circle, latitude and longitude, and a distance in kilometres
      #     which represents the radius. For convenience, longitude
      #     is allowed to wrap around 180 degrees. For example 181 is equivalent to -179.
      #   @:param clip-to-polygon: Restrict autosuggest results to a polygon, specified by a list of coordinates.
      #     The polygon should be closed, i.e. the first element should be repeated as the
      #     last element; also the list should contain at least 4 entries.
      #     The API is currently limited to accepting up to 25 pairs.
      #   @:param string input-type: For power users, used to specify voice input mode.
      #     Can be text (default), vocon-hybrid, nmdp-asr or generic-voice.
      #   @:param string prefer-land: Makes autosuggest prefer results on land to those in the sea.
      h = { input: input }
      h[:'n-results'] = params[:'n-results'].to_i if params[:'n-results']
      h[:focus] = params[:focus].join(',') if params[:focus].respond_to? :join
      h[:'n-focus-results'] = params[:'n-focus-results'].to_i if params[:'n-focus-results']
      h[:'clip-to-country'] = params[:'clip-to-country'] if params[:'clip-to-country'].respond_to? :to_str
      h[:'clip-to-bounding-box'] = params[:'clip-to-bounding-box'].join(',') if params[:'clip-to-bounding-box'].respond_to? :join
      h[:'clip-to-circle'] = params[:'clip-to-circle'].join(',') if params[:'clip-to-circle'].respond_to? :join
      h[:'clip-to-polygon'] = params[:'clip-to-polygon'].join(',') if params[:'clip-to-polygon'].respond_to? :join
      h[:'input-type'] = params[:'input-type'] if params[:'input-type'].respond_to? :to_str
      h[:'prefer-land'] = params[:'prefer-land'] if params[:'prefer-land']
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_autosuggest_request_params

    def request!(endpoint_name, params)
      # Defines HTTP request methods
      # puts endpoint(endpoint_name).inspect
      # puts params.inspect
      begin
        headers = { "X-W3W-Wrapper": "what3words-Ruby/#{WRAPPER_VERSION}" }
        response = RestClient.get endpoint(endpoint_name), params: params, headers: headers
      rescue => e
        # puts e.inspect
        # puts e.methods.sort
        response = e.response
      end
      # puts '#{response.to_str}'
      # puts 'Response status: #{response.code}'
      response = JSON.parse(response.body)
      # puts response.inspect

      if response['error'].to_s.strip != ''
        raise ResponseError, "#{response['code']}: #{response['message']}"
      end

      deep_symbolize_keys(response)

    end
    private :request!

    def get_words_string(words)
      # Returns words in string otherwise raise an issue
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
        i.each { |k, v| ni[k.respond_to?(:to_sym) ? k.to_sym : k] = deep_symbolize_keys(v) }
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
