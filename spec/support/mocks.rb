module SpecHelpers
  module Dummy
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

    def make_dummy_headers
      {
        'Authorization' => 'Signature: dummy_signature',
        'X-Saa-Auth-Time' => Time.new(2014, 11, 18).iso8601,
        'X-Saa-Key' => 'user_personal_key'
      }
    end

    def setup_dummy_signer
      signer = double
      allow(signer).to receive(:sign) { 'dummy_signature' }
      SimpleApiAuth.configure do |config|
        config.signer = signer
      end
    end
  end
end
