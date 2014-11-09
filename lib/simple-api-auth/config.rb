module SimpleApiAuth
  class Config
    attr_accessor :request_keys, :allowed_methods
    attr_accessor :signer, :request_timeout, :required_headers, :hasher
    attr_accessor :logger, :header_keys, :model_defaults

    def initialize
      reset!
    end

    def reset!
      self.model_defaults = model_default_values
      self.header_keys = default_header_keys
      self.request_keys = default_request_keys
      self.allowed_methods = [:get, :post, :put, :patch, :delete]
      self.required_headers = default_header_keys.values
      self.hasher = SimpleApiAuth::Hasher::SHA1
      self.signer = SimpleApiAuth::Signer
      self.request_timeout = 5
      self.logger = nil
    end

    private

    def default_request_keys
      {
        headers: :headers,
        http_verb: :method,
        uri: :path,
        query_string: :query_string,
        body: :body
      }
    end

    def default_header_keys
      {
        key: :x_saa_key,
        time: :x_saa_auth_time,
        authorization: :authorization
      }
    end

    def model_default_values
      {
        ssa_key: :ssa_key,
        ssa_secret: :ssa_secret
      }
    end
  end
end
