module SimpleApiAuth
  class Signer
    attr_accessor :hasher

    def initialize
      self.hasher = SimpleApiAuth.config.hasher.new
    end

    def sign(request, secret_key)
      date = request.time.strftime('%Y%m%d')
      hashed_date = hasher.hmac('ssa' + secret_key, date)
      SimpleApiAuth.log(Logger::DEBUG, "Hashed date: #{hashed_date}")

      signing_key = hasher.hmac(hashed_date, 'ssa_request')
      SimpleApiAuth.log(Logger::DEBUG, "Signing key: #{signing_key}")

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
      canonical_request_string = [
        request.http_verb,
        URI.encode(request.uri),
        URI.encode(request.query_string),
        Digest.hexencode(request.body.read)
      ].join("\n")
      SimpleApiAuth.log(Logger::DEBUG, "Canonical request string: #{canonical_request_string}")
      hasher.hash(canonical_request_string)
    end
  end
end
