module SimpleApiAuth
  class Authenticator
    attr_accessor :resource, :request, :headers, :http_verb

    def initialize(resource, request)
      self.resource = resource
      self.request = request
      init_data
    end

    def authenticate
      return false unless check_data
    end

    private

    def init_data
      self.headers = normalize_headers(request.send(SimpleApiAuth.config.headers_name))
      self.http_verb = normalize(request.send(SimpleApiAuth.config.http_verb_name))
    end

    def required_headers
      [:authorization, :x_saa_auth_time, :x_saa_key]
    end

    def normalize_headers(headers)
      normalized_headers = {}
      headers.each do |key, value|
        normalized_key = normalize(key)
        normalized_headers[normalized_key] = value
      end
      normalized_headers
    end

    def check_data
      required_headers.each do |k, _|
        return false unless headers.key?(k)
      end
      !http_verb.nil?
    end

    def normalize(s)
      s.to_s.downcase.gsub(/-/, '_').to_sym
    end
  end

  def self.authenticate(resource, request)
    authenticator = Authenticator.new(resource, request)
    authenticator.authenticate
  end
end
