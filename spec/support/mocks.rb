module SpecHelpers
  module Dummy
    def request_time
      Time.utc(2014, 11, 8, 0, 6)
    end

    def outdated_time
      Time.utc(2014, 11, 8, 0, 1)
    end

    def mock_secret_key
      'ultra_secret_key'
    end

    def mock_headers
      {
        'HTTP_AUTHORIZATION' => 'Signature: dummy_signature',
        'HTTP_X_SAA_AUTH_TIME' => request_time.iso8601,
        'HTTP_X_SAA_KEY' => 'user_personal_key'
      }
    end

    def mock_hashed_request
      Digest.hexencode(
        <<-EOF.unindent[0..-2]
          hashed:get
          /foobar
          foo=bar&baz=qux
          #{Digest.hexencode('hashed:')}
        EOF
      )
    end

    def mock_string_to_sign
      mock_headers['HTTP_X_SAA_AUTH_TIME'] + "\n" + mock_hashed_request
    end

    def mock_signature
      date = mock_request.time.strftime('%Y%m%d')
      Digest.hexencode("saa#{mock_secret_key}:#{date}:saa_request:#{mock_string_to_sign}")
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
