module SpecHelpers
  module Dummy
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
