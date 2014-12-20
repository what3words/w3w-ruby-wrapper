# encoding: utf-8

require "rest-client"

module What3Words
  class API

    class Error < RuntimeError; end
    class ResponseError < Error; end
    class WordError < Error; end

    REGEX_3_WORDS = /^\p{L}+\.\p{L}+\.\p{L}+$/u
    REGEX_ONE_WORD = /^\*[\p{L}\-0-9]{6,31}$/u

    ENDPOINTS = {
      :words_to_position => "w3w",
      :position_to_words => "position",
      :languages => "get-languages"
    }

    def initialize(params)
      @key = params.fetch(:key)
    end

    attr_reader :key

    def words_to_position(words, params = {})
      words_string = get_words_string words
      request_params = assemble_w2p_request_params(words_string, params)
      needs_ssl = needs_ssl?(request_params)
      response = request! :words_to_position, request_params, needs_ssl
      make_response(response, :position, params[:full_response])
    end

    def position_to_words(position, params = {})
      request_params = assemble_p2w_request_params(position, params)
      response = request! :position_to_words, request_params
      make_response(response, :words, params[:full_response])
    end

    def languages(params = {})
      request_params = assemble_common_request_params(params)
      response = request! :languages, request_params
      if params[:full_response]
        response
      else
        response[:languages].map {|i| i[:code]}
      end
    end

    def assemble_common_request_params(params)
      h = {:key => key}
      h[:lang] = params[:language] if params[:language]
      h[:corners] = true if params[:corners]
      h
    end
    private :assemble_common_request_params

    def assemble_w2p_request_params(words_string, params)
      h = {:string => words_string}
      h[:"oneword-password"] = params[:oneword_password] if params[:oneword_password]
      h[:email] = params[:email] if params[:email]
      h[:password] = params[:password] if params[:password]
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_w2p_request_params

    def assemble_p2w_request_params(position, params)
      h = {:position => position.join(",")}
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_p2w_request_params

    def make_response(response, part_response_key, need_full_response)
      if need_full_response
        response
      else
        response[part_response_key]
      end
    end
    private :make_response

    def request!(endpoint_name, params, needs_ssl = false)
      response = RestClient.post endpoint(endpoint_name, needs_ssl), params
      response = JSON.parse(response.body)
      if response["error"].to_s.strip != ""
        raise ResponseError, "#{response["error"]}: #{response["message"]}"
      end
      deep_symbolize_keys(response)
    end
    private :request!

    def get_words_string(words)
      if words.respond_to? :to_str
        w = words
      elsif words.respond_to? :join
        w = words.join(".")
      else
        raise Error, "Cannot get words string for #{words.inspect}"
      end
      check_words w
    end
    private :get_words_string

    def check_words(words)
      unless REGEX_3_WORDS.match(words) or REGEX_ONE_WORD.match(words)
        raise WordError, "#{words} is not valid 3 words or OneWord"
      end
      return words
    end
    private :check_words

    def deep_symbolize_keys(i)
      if i.kind_of? Hash
        ni = {}
        i.each {|k,v| ni[k.respond_to?(:to_sym) ? k.to_sym : k] = deep_symbolize_keys(v) }
      elsif i.kind_of? Array
        ni = i.map(&method(:deep_symbolize_keys))
      else
        ni = i
      end

      ni
    end

    def base_url(needs_ssl = false)
      protocol = needs_ssl ? "https" : "http"
      "#{protocol}://api.what3words.com/"
    end
    private :base_url

    def endpoint(name, needs_ssl)
      return base_url(needs_ssl) + ENDPOINTS.fetch(name)
    end

    def needs_ssl?(params)
      (params.has_key?(:email) and params.has_key?(:password)) or
        params.has_key?(:"oneword-password")
    end
    private :needs_ssl?

  end
end
