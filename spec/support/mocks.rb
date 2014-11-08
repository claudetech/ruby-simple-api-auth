module SpecHelpers
  module Dummy
    def now
      Time.new(2014, 11, 18)
    end

    def mock_secret_key
      'ultra_secret_key'
    end

    def mock_headers
      {
        'Authorization' => 'Signature: dummy_signature',
        'X-Saa-Auth-Time' => now.iso8601,
        'X-Saa-Key' => 'user_personal_key'
      }
    end

    def mock_hashed_request
      <<-EOF.unindent[0..-2]
        hashed
        get
        /foobar
        foo=bar&baz=qux

      EOF
    end

    def mock_string_to_sign
      mock_headers['X-Saa-Auth-Time'] + "\n" + mock_hashed_request
    end

    def mock_signature
      date = mock_request.time.strftime('%Y%m%d')
      Digest.hexencode("ssa#{mock_secret_key}\n#{date}\nssa_request\n#{mock_string_to_sign}")
    end

    def setup_dummy_signer
      signer = double
      allow(signer).to receive(:sign) { 'dummy_signature' }
      signer_class = double
      allow(signer_class).to receive(:new) { signer }

      SimpleApiAuth.configure do |config|
        config.signer = signer_class
      end
    end

    def rails_request
      SpecHelpers::Requests::RailsRequest.new(
        headers: mock_headers,
        method: 'GET',
        path: '/foobar',
        query_string: 'foo=bar&baz=qux'
      )
    end

    def mock_request
      SimpleApiAuth::Request.create(rails_request)
    end
  end
end
