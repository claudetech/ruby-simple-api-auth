module SpecHelpers
  module Dummy
    class RailsRequest
      attr_accessor :headers, :method
      def initialize(headers, method)
        self.headers = headers
        self.method = method
      end
    end

    class SinatraRequest
      attr_accessor :env, :request_method
      def initialize(env, request_method)
        self.env = env
        self.request_method = request_method
      end
    end

    class Resource
      attr_accessor :api_key, :api_secret_token
      def initialize(api_key, api_secret_token)
        self.api_key = api_key
        self.api_secret_token = api_secret_token
      end
    end
  end
end
