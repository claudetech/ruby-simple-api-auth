module SpecHelpers
  module Requests
    class BaseRequest
      DEFAULTS = {
        path: '/',
        query_string: '',
        body: StringIO.new('')
      }

      attr_accessor :path, :query_string, :body

      def initialize(options = {})
        options = DEFAULTS.merge(options)
        options.each do |k, v|
          send("#{k}=", v)
        end
      end

      def self.configure
      end
    end

    class RailsRequest < BaseRequest
      attr_accessor :headers, :method
    end

    class SinatraRequest < BaseRequest
      attr_accessor :env, :request_method

      def initialize(options = {})
        options[:env] = options.delete :headers
        options[:request_method] = options.delete :method
        super
      end

      def self.configure
        ::SimpleApiAuth.configure do |config|
          config.request_fields[:headers] = :env
          config.request_fields[:http_verb] = :request_method
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
