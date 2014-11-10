module SimpleApiAuth
  class Authenticator
    include SimpleApiAuth::Helpers::Auth

    attr_accessor :request, :signer

    def initialize(request, secret_key, options = {})
      self.request = SimpleApiAuth::Request.create(request)
      self.signer = SimpleApiAuth.config.signer.new
      @options = options
      @secret_key = secret_key
    end

    def valid_signature?
      return false unless check_data(request) && valid_time?(request)
      signed_request = signer.sign(request, @secret_key)
      SimpleApiAuth.log(Logger::DEBUG, "Signed request: #{signed_request}")
      SimpleApiAuth.log(Logger::DEBUG, "User signature: #{signature}")
      secure_equals?(signed_request, signature, @secret_key)
    end

    private

    def signature
      extract_signature(headers)
    end

    def headers
      request.headers
    end
  end
end
