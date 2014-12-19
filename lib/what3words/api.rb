# encoding: utf-8

require "rest-client"

module What3Words
  class API

    class Error < RuntimeError; end
    class ResponseError < Error; end
    class WordError < Error; end

    REGEX_3_WORDS = /^\p{L}+\.\p{L}+\.\p{L}+$/u
    REGEX_ONE_WORD = /^\*[\p{L}\-0-9]{6,31}$/u

    def deep_symbolize_keys(hash)
      nh = {}
      hash.each do |k, v|
        nh[k.to_sym] = v
      end
      nh
    end

    BASE_URL = "http://api.what3words.com/"

    ENDPOINTS = {
      :words_to_position => "w3w",
      :position_to_words => "position",
      :languages => "get-languages"
    }

    def endpoint(name)
      return BASE_URL + ENDPOINTS.fetch(name)
    end

    def initialize(params)
      @key = params.fetch(:key)
    end

    attr_reader :key

    def words_to_position(words, params = {})
      words_string = get_words_string words
      response = get :words_to_position, :string => words_string,
        :key => key, :lang => params[:language]

      if params[:full_response]
        response
      else
        response[:position]
      end
    end

    def get(endpoint_name, params)
      response = RestClient.get endpoint(endpoint_name), :params => params
      if response["error"].to_s.strip != ""
        raise ResponseError, response["error"] + ": " + response["message"]
      end
      deep_symbolize_keys(JSON.parse(response.body))
    end
    private :get

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
      raise WordError, "#{words} is not valid 3 words" unless REGEX_3_WORDS.match(words)
      return words
    end
    private :check_words
  end
end
