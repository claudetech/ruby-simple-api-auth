module SimpleApiAuth
  class Authenticator
    def init(resource, request)
      @resource = resource
      @request = request
    end

    def authenticate
      return false unless check_data
    end

    private

    def init_data
      @headers = normalize_headers(request.send(SimpleApiAuth.config.headers_name))
      @http_verb = request.send(SimpleApiAuth.config.http_verb_name)
    end

    def needed_headers
      [:signature, :content_type, :x_auth_time, :x_resource_id]
    end

    def normalize_headers(headers)
      normalized_headers = {}
      headers.each do |key, value|
        normalized_key = key.downcase.gsub(/-/, '_')
        normalized_headers[normalized_key] = value
      end
      normalized_headers
    end

    def check_data
      needed_headers.each do |k, _|
        return false unless @headers.key?(k)
      end
      return false unless
      true
    end
  end

  def self.authenticate(resource, request)
    authenticator = Authenticator.new(resource, request)
    authenticator.authenticate
  end
end
