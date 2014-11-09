module SimpleApiAuth
  module Helpers
    module Auth
      def extract_signature(headers)
        header_key = SimpleApiAuth.config.header_keys[:authorization]
        match = /Signature: (.+)/.match(headers[header_key])
        match && match[1]
      end

      def required_headers
        options[:required_headers] || SimpleApiAuth.config.required_headers
      end

      def request_timeout
        (options[:request_timeout] || SimpleApiAuth.config.request_timeout) * 60
      end

      def allowed_methods
        options[:allowed_methods] || SimpleApiAuth.config.allowed_methods
      end

      def options
        @options || {}
      end

      def check_data(request)
        required_headers.each do |k, _|
          return false unless request.headers.key?(k)
        end
        allowed_methods.include?(request.http_verb)
      end

      def too_old?(request)
        request_time = request.time
        return false if request_time.nil?
        difference = Time.now - request_time
        difference < 0 || difference > request_timeout
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
