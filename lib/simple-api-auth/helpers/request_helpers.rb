module SimpleApiAuth
  module Helpers
    module Request
      def normalize_headers(headers)
        normalized_headers = {}
        headers.each do |key, value|
          normalized_key = normalize(key)
          normalized_headers[normalized_key] = value
        end
        normalized_headers
      end

      def normalize(s)
        s.to_s.downcase.gsub(/-/, '_').to_sym
      end
    end
  end
end
