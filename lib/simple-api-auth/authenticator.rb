module SimpleApiAuth
  class Authenticator
    include ::SimpleApiAuth::RequestHelpers

    attr_accessor :request, :headers, :http_verb, :signer

    def initialize(request, secret_key)
      self.request = request
      self.signer = SimpleApiAuth.config.signer
      @secret_key = secret_key
      init_data
    end

    def authenticate
      return false if !check_data(headers) || too_old?(headers)
      signed_request = signer.sign(request, @secret_key)
      secure_equals?(signed_request, user_signature, @secret_key)
    end

    private

    def init_data
      self.headers = normalize_headers(request.send(SimpleApiAuth.config.headers_name))
      self.http_verb = normalize(request.send(SimpleApiAuth.config.http_verb_name))
    end

    def user_signature
      get_signature(headers)
    end
  end

  def self.authenticate(request, secret_key)
    authenticator = Authenticator.new(request, secret_key)
    authenticator.authenticate
  end
end
