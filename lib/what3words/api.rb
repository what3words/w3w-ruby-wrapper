# encoding: utf-8

require "rest-client"

module What3Words
  class API

    class Error < RuntimeError; end
    class ResponseError < Error; end
    class WordError < Error; end

    REGEX_3_WORD_ADDRESS = /^\p{L}+\.\p{L}+\.\p{L}+$/u
    REGEX_STRICT = /^\p{L}{4,}+\.\p{L}{4,}+\.\p{L}{4,}+$/u

    BASE_URL = "https://api.what3words.com/v2/"

    ENDPOINTS = {
      :forward => "forward",
      :reverse => "reverse",
      :languages => "languages",
      :autosuggest => "autosuggest"
    }

    def initialize(params)
      @key = params.fetch(:key)
    end

    attr_reader :key

    def forward(words, params = {})
      words_string = get_words_string words
      request_params = assemble_forward_request_params(words_string, params)
      response = request! :forward, request_params
      response
    end

    def reverse(position, params = {})
      request_params = assemble_reverse_request_params(position, params)
      response = request! :reverse, request_params
      response
    end

    def languages()
      request_params = assemble_common_request_params({})
      response = request! :languages, request_params
      response
    end

    def autosuggest(addr, lang, focus = {}, clip = {}, params = {})
      request_params = assemble_autosuggest_request_params(addr, lang, focus, clip, params)
      response = request! :autosuggest, request_params
      response
    end

    def assemble_common_request_params(params)
      h = {:key => key}
      h[:lang] = params[:lang] if params[:lang]
      h[:format] = params[:format] if params[:format]
      h[:display] = params[:format] if params[:format]
      h
    end
    private :assemble_common_request_params

    def assemble_forward_request_params(words_string, params)
      h = {:addr => words_string}
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_forward_request_params

    def assemble_reverse_request_params(position, params)
      h = {:coords => position.join(",")}
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_reverse_request_params

    def assemble_autosuggest_request_params(addr, lang, focus, clip, params)
      h = {:addr => addr}
      h[:lang] = lang
      if focus.respond_to? :join
        h[:focus] = focus.join(",")
      end
      h[:clip] = clip if clip.respond_to? :to_str
      h.merge(assemble_common_request_params(params))
    end
    private :assemble_autosuggest_request_params

    def request!(endpoint_name, params)
      # puts endpoint_name.inspect
      # puts params.inspect
      begin
        response = RestClient.get endpoint(endpoint_name), params: params
      rescue => e
        response = e.response
      end
      # puts "#{response.to_str}"
      # puts "Response status: #{response.code}"
      response = JSON.parse(response.body)
      if response["code"].to_s.strip != ""
        raise ResponseError, "#{response["code"]}: #{response["message"]}"
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
      unless REGEX_3_WORD_ADDRESS.match(words)
        raise WordError, "#{words} is not a valid 3 word address"
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

    def base_url()
      BASE_URL
    end
    private :base_url

    def endpoint(name)
      return base_url() + ENDPOINTS.fetch(name)
    end

  end
end
