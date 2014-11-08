module SimpleApiAuth
  class Signer
    attr_accessor :hasher

    def initialize(options = {})
      hahser_class = options[:hasher] || SimpleApiAuth.config.hasher
      self.hasher = hahser_class.new
    end

    def sign(request, secret_key)
      signing_key = make_singing_key(request, secret_key)
      SimpleApiAuth.log(Logger::DEBUG, "Signing key(hex): #{Digest.hexencode(signing_key)}")

      string_to_sign = make_string_to_sign(request)
      SimpleApiAuth.log(Logger::DEBUG, "String to sign: #{string_to_sign}")

      signature = hasher.hmac(signing_key, string_to_sign)
      Digest.hexencode(signature)
    end

    def make_string_to_sign(request)
      hashed_request = make_hashed_request(request)
      SimpleApiAuth.log(Logger::DEBUG, "Hashed request: #{hashed_request}")
      [
        request.time.iso8601,
        hashed_request
      ].join("\n")
    end

    def make_hashed_request(request)
      canonical_request_string = make_canonical_request(request)
      SimpleApiAuth.log(Logger::DEBUG, "Canonical request string: #{canonical_request_string}")
      Digest.hexencode(hasher.hash(canonical_request_string))
    end

    private

    def make_singing_key(request, secret_key)
      date = request.time.strftime('%Y%m%d')
      hashed_date = hasher.hmac('ssa' + secret_key, date)
      hasher.hmac(hashed_date, 'ssa_request')
    end

    def make_canonical_request(request)
      [
        request.http_verb,
        URI.encode(request.uri),
        URI.encode(request.query_string),
        Digest.hexencode(hasher.hash(request.body.read))
      ].join("\n")
    end
  end
end
