module SpecHelpers
  module Requests
    class RailsRequest
      attr_accessor :headers, :method
      def initialize(headers, method)
        self.headers = headers
        self.method = method
      end
      def self.configure
      end
    end

    class SinatraRequest
      attr_accessor :env, :request_method
      def initialize(env, request_method)
        self.env = env
        self.request_method = request_method
      end

      def self.configure
        ::SimpleApiAuth.configure do |config|
          config.headers_name = :env
          config.http_verb_name = :request_method
        end
      end
    end

    def requests
      {
        'rails request'   => RailsRequest,
        'sinatra request' => SinatraRequest
      }
    end
  end
end
