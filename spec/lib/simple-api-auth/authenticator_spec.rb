describe SimpleApiAuth do
  describe SimpleApiAuth::Authenticator do
    include SimpleApiAuth::Helpers::Request

    let(:dummy_headers) { make_dummy_headers }

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
      expect(authenticator.headers).to eq(normalize_headers(dummy_headers))
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
