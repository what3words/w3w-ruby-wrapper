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
      request_params = assemble_request_params(words_string, params)
      needs_ssl = needs_ssl?(request_params)
      response = request! :words_to_position, request_params, needs_ssl

      if params[:full_response]
        response
      else
        response[:position]
      end
    end

    def assemble_request_params(words_string, params)
      h = {:string => words_string, :key => key}
      h[:lang] = params[:language] if params[:language]
      h[:corners] = true if params[:corners]
      h[:"oneword-password"] = params[:oneword_password] if params[:oneword_password]
      h[:email] = params[:email] if params[:email]
      h[:password] = params[:password] if params[:password]
      h
    end

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

    def deep_symbolize_keys(hash)
      nh = {}
      hash.each do |k, v|
        nk = k.to_sym

        if v.kind_of?(Hash)
          nv = deep_symbolize_keys(v)
        else
          nv = v
        end
        nh[nk] = nv
      end
      nh
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
