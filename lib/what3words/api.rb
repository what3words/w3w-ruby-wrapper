# frozen_string_literal: true

require 'rest-client'
require 'json'
require File.expand_path('../version', __FILE__)
require 'what3words/version'

module What3Words
  # What3Words v3 API wrapper
  class API
    class Error < RuntimeError; end
    class ResponseError < Error; end
    class WordError < Error; end

    REGEX_3_WORD_ADDRESS = /^\/*(?:[^0-9`~!@#$%^&*()+\-_=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]{1,}[.｡。･・︒។։။۔።।][^0-9`~!@#$%^&*()+\-_=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]{1,}[.｡。･・︒។։။۔።।][^0-9`~!@#$%^&*()+\-_=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]{1,}|[<.,>?\/\";:£§º©®\s]+[.｡。･・︒។։။۔።।][^0-9`~!@#$%^&*()+\-_=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]+|[^0-9`~!@#$%^&*()+\-_=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]+([\u0020\u00A0][^0-9`~!@#$%^&*()+\-_=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]+){1,3}[.｡。･・︒។։။۔።।][^0-9`~!@#$%^&*()+\-_=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]+([\u0020\u00A0][^0-9`~!@#$%^&*()+\-_=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]+){1,3}[.｡。･・︒។։။۔።।][^0-9`~!@#$%^&*()+\-_=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]+([\u0020\u00A0][^0-9`~!@#$%^&*()+\-_=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]+){1,3})$/u.freeze
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
      """
      Take a 3 word address and turn it into a pair of coordinates.

      Params
      ------
      :param string words: A 3 word address as a string
      :param string format: Return data format type; can be one of json (the default), geojson
      :rtype: Hash
      """
      words_string = get_words_string(words)
      request_params = assemble_convert_to_coordinates_request_params(words_string, params)
      request!(:convert_to_coordinates, request_params)
    end

    def convert_to_3wa(position, params = {})
      """
      Take latitude and longitude coordinates and turn them into a 3 word address.

      Params
      ------
      :param array position: The coordinates of the location to convert to 3 word address
      :param string format: Return data format type; can be one of json (the default), geojson
      :param string language: A supported 3 word address language as an ISO 639-1 2 letter code.
      :rtype: Hash
      """
      request_params = assemble_convert_to_3wa_request_params(position, params)
      request!(:convert_to_3wa, request_params)
    end

    def grid_section(bbox, params = {})
      """
      Returns a section of the 3m x 3m what3words grid for a given area.

      Params
      ------
      :param string bbox: Bounding box, specified by the northeast and southwest corner coordinates,
      :param string format: Return data format type; can be one of json (the default), geojson
      :rtype: Hash
      """
      request_params = assemble_grid_request_params(bbox, params)
      request!(:grid_section, request_params)
    end

    def available_languages
      """
      Retrieve a list of available 3 word languages.

      :rtype: Hash
      """
      request_params = assemble_common_request_params({})
      request!(:available_languages, request_params)
    end

    def autosuggest(input, params = {})
      """
      Returns a list of 3 word addresses based on user input and other parameters.

      Params
      ------
      :param string input: The full or partial 3 word address to obtain suggestions for.
      :param int n_results: The number of AutoSuggest results to return.
      :param array focus: A location, specified as a latitude,longitude used to refine the results.
      :param int n_focus_results: Specifies the number of results (must be <= n_results) within the results set which will have a focus.
      :param string clip_to_country: Restricts autosuggest to only return results inside the countries specified by comma-separated list of uppercase ISO 3166-1 alpha-2 country codes.
      :param array clip_to_bounding_box: Restrict autosuggest results to a bounding box, specified by coordinates.
      :param array clip_to_circle: Restrict autosuggest results to a circle, specified by the center of the circle, latitude and longitude, and a distance in kilometres which represents the radius.
      :param array clip_to_polygon: Restrict autosuggest results to a polygon, specified by a list of coordinates.
      :param string input_type: For power users, used to specify voice input mode. Can be text (default), vocon-hybrid, nmdp-asr or generic-voice.
      :param string prefer_land: Makes autosuggest prefer results on land to those in the sea.
      :param string language: A supported 3 word address language as an ISO 639-1 2 letter code.
      :rtype: Hash
      """
      request_params = assemble_autosuggest_request_params(input, params)
      request!(:autosuggest, request_params)
    end

    def isPossible3wa(text)
      """
      Determines if the string passed in is the form of a three word address.
      This does not validate whether it is a real address as it returns true for x.x.x

      Params
      ------
      :param string text: text to check
      :rtype: Boolean
      """
      regex_match = REGEX_3_WORD_ADDRESS
      !(text.match(regex_match).nil?)
    end

    def findPossible3wa(text)
      """
      Searches the string passed in for all substrings in the form of a three word address.
      This does not validate whether it is a real address as it will return x.x.x as a result

      Params
      ------
      :param string text: text to check
      :rtype: Array
      """
      regex_search = /[^\d`~!@#$%^&*()+\-=\[\]{}\\|'<>.,?\/\";:£§º©®\s]{1,}[.｡。･・︒។։။۔።।][^\d`~!@#$%^&*()+\-=\[\]{}\\|'<>.,?\/\";:£§º©®\s]{1,}[.｡。･・︒។։။۔።।][^\d`~!@#$%^&*()+\-=\[\]{}\\|'<>.,?\/\";:£§º©®\s]{1,}/u
      text.scan(regex_search)
    end

    def didYouMean(text)
      """
      Determines if the string passed in is almost in the form of a three word address.
      This will return True for values such as 'filled-count-soap' and 'filled count soap'

      Params
      ------
      :param string text: text to check
      :rtype: Boolean
      """
      regex_didyoumean = /^\/?[^0-9`~!@#$%^&*()+\-=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]{1,}[.\uFF61\u3002\uFF65\u30FB\uFE12\u17D4\u0964\u1362\u3002:။^_۔։ ,\\\/+'&\\:;|\u3000-]{1,2}[^0-9`~!@#$%^&*()+\-=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]{1,}[.\uFF61\u3002\uFF65\u30FB\uFE12\u17D4\u0964\u1362\u3002:။^_۔։ ,\\\/+'&\\:;|\u3000-]{1,2}[^0-9`~!@#$%^&*()+\-=\[\{\]}\\|'<>.,?\/\";:£§º©®\s]{1,}$/u
      !(text.match(regex_didyoumean).nil?)
    end

    def isValid3wa(text)
      """
      Determines if the string passed in is a real three word address. It calls the API
      to verify it refers to an actual place on earth.

      Params
      ------
      :param String text: text to check

      :rtype: Boolean
      """
      if isPossible3wa(text)
        result = autosuggest(text, 'n-results': 1)
        if result[:suggestions] && result[:suggestions].length > 0
          return result[:suggestions][0][:words] == text
        end
      end
      false
    end

    private

    def request!(endpoint_name, params)
      headers = { "X-W3W-Wrapper": "what3words-Ruby/#{WRAPPER_VERSION}" }
      response = RestClient.get(endpoint(endpoint_name), params: params, headers: headers)
      parsed_response = JSON.parse(response.body)

      raise ResponseError, "#{parsed_response['code']}: #{parsed_response['message']}" if parsed_response['error'].to_s.strip != ''

      deep_symbolize_keys(parsed_response)
    rescue RestClient::ExceptionWithResponse => e
      handle_rest_client_error(e)
    end

    def handle_rest_client_error(error)
      parsed_response = JSON.parse(error.response)
      raise ResponseError, "#{parsed_response['code']}: #{parsed_response['message']}" if parsed_response['error']
      raise error
    end

    def get_words_string(words)
      words_string = words.is_a?(Array) ? words.join('.') : words.to_s
      check_words(words_string)
      words_string
    end

    def check_words(words)
      raise WordError, "#{words} is not a valid 3 word address" unless REGEX_3_WORD_ADDRESS.match?(words)
    end

    def assemble_common_request_params(params)
      { key: key }.merge(params.slice(:language, :format))
    end

    def assemble_convert_to_coordinates_request_params(words_string, params)
      { words: words_string }.merge(assemble_common_request_params(params))
    end

    def assemble_convert_to_3wa_request_params(position, params)
      { coordinates: position.join(',') }.merge(assemble_common_request_params(params))
    end

    def assemble_grid_request_params(bbox, params)
      { 'bounding-box': bbox }.merge(assemble_common_request_params(params))
    end

    def assemble_autosuggest_request_params(input, params)
      result = { input: input }
      result[:'n-results'] = params[:'n-results'].to_i if params[:'n-results']
      result[:focus] = params[:focus].join(',') if params[:focus].respond_to?(:join)
      result[:'n-focus-results'] = params[:'n-focus-results'].to_i if params[:'n-focus-results']
      result[:'clip-to-country'] = params[:'clip-to-country'] if params[:'clip-to-country'].respond_to?(:to_str)
      result[:'clip-to-bounding-box'] = params[:'clip-to-bounding-box'].join(',') if params[:'clip-to-bounding-box'].respond_to?(:join)
      result[:'clip-to-circle'] = params[:'clip-to-circle'].join(',') if params[:'clip-to-circle'].respond_to?(:join)
      result[:'clip-to-polygon'] = params[:'clip-to-polygon'].join(',') if params[:'clip-to-polygon'].respond_to?(:join)
      result[:'input-type'] = params[:'input-type'] if params[:'input-type'].respond_to?(:to_str)
      result[:'prefer-land'] = params[:'prefer-land'] if params[:'prefer-land']
      result.merge(assemble_common_request_params(params))
    end

    def deep_symbolize_keys(value)
      case value
      when Hash
        value.transform_keys(&:to_sym).transform_values { |v| deep_symbolize_keys(v) }
      when Array
        value.map { |v| deep_symbolize_keys(v) }
      else
        value
      end
    end

    def endpoint(name)
      BASE_URL + ENDPOINTS.fetch(name)
    end
  end
end
