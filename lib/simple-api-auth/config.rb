module SimpleApiAuth
  class Config
    attr_accessor :request_fields, :allowed_methods, :request_normalizer
    attr_accessor :signer, :request_timeout, :required_headers, :hasher
    attr_accessor :logger, :header_keys, :model_defaults

    def initialize
      reset!
    end

    def reset!
      self.request_normalizer = SimpleApiAuth::Helpers::RequestNormalizer
      self.model_defaults = model_default_values
      self.header_keys = default_header_keys
      self.request_fields = default_request_fields
      self.allowed_methods = [:get, :post, :put, :patch, :delete]
      self.required_headers = default_header_keys.values
      self.hasher = SimpleApiAuth::Hasher::SHA1
      self.signer = SimpleApiAuth::Signer
      self.request_timeout = 5
      self.logger = nil
    end

    def make_model_options(options)
      options = model_defaults.merge(options)
      if options[:auto_generate].is_a?(Symbol)
        options[:auto_generate] = [options[:auto_generate]]
      elsif !options[:auto_generate].is_a?(Array)
        options[:auto_generate] = options[:auto_generate] ? [:saa_key, :saa_secret] : []
      end
      options
    end

    private

    def default_request_fields
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
        saa_key: :http_x_saa_key,
        saa_auth_time: :http_x_saa_auth_time,
        authorization: :http_authorization
      }
    end

    def model_default_values
      {
        saa_key: :saa_key,
        saa_secret: :saa_secret,
        auto_generate: []
      }
    end
  end
end
