module SimpleApiAuth
  module Helpers
    class RequestNormalizer
      def normalize_headers(headers)
        normalized_headers = {}
        headers.each do |key, value|
          normalized_key = normalize(key)
          normalized_headers[normalized_key] = value
        end
        normalized_headers
      end

      def normalize(key)
        key.to_s.downcase.gsub(/-/, '_').to_sym
      end

      def denormalize(key)
        key.to_s.upcase
      end
    end
  end
end
