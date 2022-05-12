# encoding: utf-8

require 'rest-client'

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
      convert_to_coordinates: 'convert_to_coordinates',
      convert_to_3wa: 'convert-to-3wa',
      available_languages: 'available_languages',
      autosuggest: 'autosuggest',
      standardblend: 'standardblend',
      autosuggest_ml: 'autosuggest-ml',
      standardblend_ml: 'standardblend-ml',
      grid_section: 'grid_section'
    }.freeze

    def initialize(params)
      @key = params.fetch(:key)
    end

    attr_reader :key

    def convert_to_coordinates(words, params = {})
      words_string = get_words_string words
      request_params = assemble_forward_request_params(words_string, params)
      response = request! :convert_to_coordinates, request_params
      response
    end

    def convert_to_3wa(position, params = {})
      request_params = assemble_reverse_request_params(position, params)
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

    def autosuggest(addr, language, focus = {}, clip = {}, params = {})
      request_params = assemble_autosuggest_request_params(addr, language, focus,
                                                           clip, params)
      response = request! :autosuggest, request_params
      response
    end

    def autosuggest_ml(addr, language, focus = {}, clip = {}, params = {})
      request_params = assemble_autosuggest_request_params(addr, language, focus,
                                                           clip, params)
      response = request! :autosuggest_ml, request_params
      response
    end

    def standardblend(addr, language, focus = {}, params = {})
      request_params = assemble_standardblend_request_params(addr, language, focus,
                                                             params)
      response = request! :standardblend, request_params
      response
    end

    def standardblend_ml(addr, language, focus = {}, params = {})
      request_params = assemble_standardblend_request_params(addr, language, focus,
                                                             params)
      response = request! :standardblend_ml, request_params
      response
    end

    def assemble_common_request_params(params)
      h = { key: key }
      h[:language] = params[:language] if params[:language]
      h[:format] = params[:format] if params[:format]
      h[:display] = params[:display] if params[:display]
      h
    end
    private :assemble_common_request_params

    def assemble_forward_request_params(words_string, params)
      h = { addr: words_string }
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_forward_request_params

    def assemble_grid_request_params(bbox, params)
      h = { bbox: bbox }
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_grid_request_params

    def assemble_reverse_request_params(position, params)
      h = { coordinates: position.join(',') }
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_reverse_request_params

    def assemble_autosuggest_request_params(addr, language, focus, clip, params)
      h = { addr: addr }
      h[:language] = language
      h[:focus] = focus.join(',') if focus.respond_to? :join
      h[:clip] = clip if clip.respond_to? :to_str
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_autosuggest_request_params

    def assemble_standardblend_request_params(addr, language, focus, params)
      h = { addr: addr }
      h[:language] = language
      h[:focus] = focus.join(',') if focus.respond_to? :join
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_standardblend_request_params

    def request!(endpoint_name, params)
      # puts endpoint_name.inspect
      # puts params.inspect
      begin
        response = RestClient.get endpoint(endpoint_name), params: params
      rescue => e
        response = e.response
      end
      # puts '#{response.to_str}'
      # puts 'Response status: #{response.code}'
      response = JSON.parse(response.body)
      if response['code'].to_s.strip != ''
        raise ResponseError, "#{response['code']}: #{response['message']}"
      end
      deep_symbolize_keys(response)
    end
    private :request!

    def get_words_string(words)
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
