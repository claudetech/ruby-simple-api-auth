module SimpleApiAuth
  module RequestHelpers
    def get_signature(headers)
      match = /Signature: (.+)/.match(headers[:authorization])
      match && match[1]
    end

    def required_headers
      SimpleApiAuth.config.required_headers
    end

    def request_timeout
      SimpleApiAuth.config.request_timeout * 60
    end

    def normalize_headers(headers)
      normalized_headers = {}
      headers.each do |key, value|
        normalized_key = normalize(key)
        normalized_headers[normalized_key] = value
      end
      normalized_headers
    end

    def check_data(headers)
      required_headers.each do |k, _|
        return false unless headers.key?(k)
      end
      !http_verb.nil?
    end

    def too_old?(headers)
      request_time = Time.parse(headers[:x_saa_auth_time]) rescue nil
      return false if request_time.nil?
      Time.now - request_time > request_timeout
    end

    def normalize(s)
      s.to_s.downcase.gsub(/-/, '_').to_sym
    end

    def secure_equals?(m1, m2, key)
      sha1_hmac(key, m1) == sha1_hmac(key, m2)
    end

    def sha1_hmac(key, message)
      digest = OpenSSL::Digest.new('sha1')
      OpenSSL::HMAC.digest(digest, key, message)
    end
  end
end
