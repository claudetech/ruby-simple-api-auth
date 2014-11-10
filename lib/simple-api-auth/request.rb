module SimpleApiAuth
  class Request
    attr_accessor :headers, :http_verb, :query_string, :uri, :body, :original

    def initialize(options = {})
      assign_options(options)
      @normalizer = SimpleApiAuth.config.request_normalizer.new
      @header_field = SimpleApiAuth.config.request_fields[:headers]
      self.headers = @normalizer.normalize_headers(headers)
      self.http_verb = http_verb.downcase.to_sym
    end

    def time
      header_key = SimpleApiAuth.config.header_keys[:time]
      Time.parse(headers[header_key])
    rescue ArgumentError, TypeError
      nil
    end

    def add_header(key, value)
      headers[key] = value
      denormalized_key = @normalizer.denormalize(key)
      original.send(@header_field)[denormalized_key] = value
    end

    def self.create(request)
      return request if request.is_a?(Request)
      options = {}
      SimpleApiAuth.config.request_fields.each do |k, v|
        options[k] = request.send(v)
      end
      Request.new(options.merge(original: request))
    end

    private

    def assign_options(options)
      options.each do |k, v|
        send("#{k}=", v)
      end
    end
  end
end
