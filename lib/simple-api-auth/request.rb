module SimpleApiAuth
  class Request
    include SimpleApiAuth::Helpers::Request

    attr_accessor :headers, :http_verb, :query_string, :uri, :body

    def initialize(options = {})
      options.each do |k, v|
        send("#{k}=", v)
      end
      self.headers = normalize_headers(headers)
      self.http_verb = normalize(http_verb)
    end

    def time
      header_key = SimpleApiAuth.config.header_keys[:time]
      Time.parse(headers[header_key])
    rescue ArgumentError, TypeError
      nil
    end

    def self.create(request)
      if request.is_a?(Request)
        request
      else
        options = {}
        SimpleApiAuth.config.request_fields.each do |k, v|
          options[k] = request.send(v)
        end
        Request.new(options)
      end
    end
  end
end
