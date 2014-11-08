module SimpleApiAuth
  class Config
    attr_accessor :headers_name, :http_verb_name, :allowed_methods

    def initialize
      self.headers_name = :headers
      self.http_verb_name = :method
      self.allowed_methods = [:get, :post, :put, :patch, :delete]
    end
  end
end
