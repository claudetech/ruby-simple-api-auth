describe SimpleApiAuth do
  describe SimpleApiAuth::Authenticator do

    let(:dummy_headers) do
      {
        'Authorization' => 'Signature: dummy_signature',
        'X-Saa-Auth-Time' => Time.new(2014, 11, 18).iso8601,
        'X-Saa-Key' => 'user_personal_key'
      }
    end
    let(:secret_key) { 'ultra_secret_key' }
    let(:dummy_request) { SpecHelpers::Dummy::RailsRequest.new(dummy_headers, 'GET') }
    let(:authenticator) { SimpleApiAuth::Authenticator.new(dummy_request, secret_key) }

    before(:each) do
      allow(Time).to receive(:now) { Time.new(2014, 11, 18, 0, 3) }
      signer = double
      allow(signer).to receive(:sign) { 'dummy_signature' }
      SimpleApiAuth.configure do |config|
        config.signer = signer
      end
    end

    it 'should set verb' do
      expect(authenticator.http_verb).to eq(:get)
    end

    it 'should set headers' do
      [:authorization, :x_saa_auth_time, :x_saa_key].each do |key|
        expect(authenticator.headers).to include(key)
      end
      expect(authenticator.headers.values).to eq(dummy_headers.values)
    end

    it 'should fail on missing header' do
      dummy_headers.delete 'X-Saa-Key'
      expect(authenticator.authenticate).to be_falsy
    end

    it 'should fail on outdated request' do
      allow(Time).to receive(:now) { Time.new(2014, 11, 18, 0, 6) }
      expect(authenticator.authenticate).to be_falsy
    end

    it 'should compare signature otherwise' do
      expect(authenticator.authenticate).to be_truthy
    end
  end
end
