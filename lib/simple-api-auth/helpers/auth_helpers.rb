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
          return log_and_fail(missing_header_message(k)) unless request.headers.key?(k)
        end
        allowed_verb = allowed_methods.include?(request.http_verb)
        return log_and_fail("verb #{request.http_verb} not allowed") unless allowed_verb
        true
      end

      def missing_header_message(header_name)
        available_headers = request.headers.keys.join(', ')
        "missing header #{header_name}. available headers are: #{available_headers}"
      end

      def valid_time?(request)
        request_time = request.time
        return log_and_fail('request time not found') if request_time.nil?
        difference = Time.now - request_time
        return log_and_fail('negative time') if difference < 0
        return log_and_fail('request too old') if difference > request_timeout
        true
      end

      def log_and_fail(message)
        SimpleApiAuth.log(Logger::DEBUG, message)
        false
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
