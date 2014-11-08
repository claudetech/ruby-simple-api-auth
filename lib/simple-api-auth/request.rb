module SimpleApiAuth
  class Request
    include SimpleApiAuth::Helpers::Request

    attr_accessor :headers, :http_verb, :query_string, :uri, :body

    def initialize(request)
      SimpleApiAuth.config.request_keys.each do |k, v|
        send("#{k}=", request.send(v))
      end
      self.headers = normalize_headers(headers)
      self.http_verb = normalize(http_verb)
    end

    def time
      Time.parse(headers[:x_saa_auth_time])
    rescue ArgumentError
      nil
    end

    def self.create(request)
      if request.is_a?(Request)
        request
      else
        Request.new(request)
      end
    end
  end
end
