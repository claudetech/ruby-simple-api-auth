module SimpleApiAuth
  module Helpers
    module Auth
      def extract_signature(headers)
        match = /Signature: (.+)/.match(headers[:authorization])
        match && match[1]
      end

      def required_headers
        SimpleApiAuth.config.required_headers
      end

      def request_timeout
        SimpleApiAuth.config.request_timeout * 60
      end

      def check_data(request)
        required_headers.each do |k, _|
          return false unless request.headers.key?(k)
        end
        SimpleApiAuth.config.allowed_methods.include?(request.http_verb)
      end

      def too_old?(request)
        request_time = request.time
        return false if request_time.nil?
        Time.now - request_time > request_timeout
      end

      def secure_equals?(m1, m2, key)
        sha1_hmac(key, m1) == sha1_hmac(key, m2)
      end

      def sha1_hmac(key, message)
        SimpleApiAuth::Hasher::SHA1.new.hmac(key, message)
      end
    end
  end
end
