module SimpleApiAuth
  class Config
    attr_accessor :headers_name, :http_verb_name, :allowed_methods
    attr_accessor :signer, :request_timeout, :required_headers

    def initialize
      reset!
    end

    def reset!
      self.headers_name = :headers
      self.http_verb_name = :method
      self.allowed_methods = [:get, :post, :put, :patch, :delete]
      self.required_headers = [:authorization, :x_saa_auth_time, :x_saa_key]
      self.signer = nil
      self.request_timeout = 5
    end
  end
end
