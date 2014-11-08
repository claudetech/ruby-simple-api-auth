module SpecHelpers
  module Dummy
    def now
      Time.new(2014, 11, 18)
    end

    def make_dummy_headers
      {
        'Authorization' => 'Signature: dummy_signature',
        'X-Saa-Auth-Time' => now.iso8601,
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

    def rails_request
      SpecHelpers::Requests::RailsRequest.new(
        headers: make_dummy_headers,
        method: 'GET',
        path: '/foobar',
        query_string: 'foo=bar&baz=qux'
      )
    end
  end
end
