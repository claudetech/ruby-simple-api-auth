module SimpleApiAuth
  class Signer
    attr_accessor :hasher

    def initialize
      self.hasher = SimpleApiAuth.config.hasher.new
    end

    def sign(request, secret_key)
      date = request.time.strftime('%Y%m%d')
      hashed_date = hasher.hmac('ssa' + secret_key, date)
      signature = hasher.hmac(hashed_date, 'ssa_request')
      Digest.hexencode(signature)
    end

    def make_string_to_sign(request)
      hashed_request = make_hashed_request(request)
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
      hasher.hash(canonical_request_string)
    end
  end
end
