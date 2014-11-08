module SimpleApiAuth
  class Config
    attr_accessor :request_keys, :allowed_methods
    attr_accessor :signer, :request_timeout, :required_headers, :hasher

    def initialize
      reset!
    end

    def reset!
      self.request_keys = {
        headers: :headers,
        http_verb: :method,
        uri: :path,
        query_string: :query_string,
        body: :body
      }
      self.allowed_methods = [:get, :post, :put, :patch, :delete]
      self.required_headers = [:authorization, :x_saa_auth_time, :x_saa_key]
      self.hasher = SimpleApiAuth::Hasher::SHA1
      self.signer = SimpleApiAuth::Signer
      self.request_timeout = 5
    end
  end
end
