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

      def check_data(headers, http_verb)
        required_headers.each do |k, _|
          return false unless headers.key?(k)
        end
        SimpleApiAuth.config.allowed_methods.include?(http_verb)
      end

      def too_old?(headers)
        request_time = Time.parse(headers[:x_saa_auth_time]) rescue nil
        return false if request_time.nil?
        Time.now - request_time > request_timeout
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
end
