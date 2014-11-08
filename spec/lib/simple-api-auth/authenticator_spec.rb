describe SimpleApiAuth do
  describe SimpleApiAuth::Authenticator do
    include SimpleApiAuth::Helpers::Request

    let(:dummy_headers) { make_dummy_headers }

    let(:secret_key) { 'ultra_secret_key' }
    let(:authenticator) { SimpleApiAuth::Authenticator.new(dummy_request, secret_key) }

    before(:each) do
      allow(Time).to receive(:now) { Time.new(2014, 11, 18, 0, 3) }
      setup_dummy_signer
    end

    {
      'with rails request' => SpecHelpers::Dummy::RailsRequest,
      'with sinatra request' => SpecHelpers::Dummy::SinatraRequest
    }.each do |context_name, request |
      context context_name do
        before(:each) { request.configure }
        let(:dummy_request) { request.new(dummy_headers, 'GET') }

        it 'should set verb' do
          expect(authenticator.http_verb).to eq(:get)
        end

        it 'should set headers' do
          expect(authenticator.headers).to eq(normalize_headers(dummy_headers))
        end

        it 'should fail on missing header' do
          dummy_headers.delete 'X-Saa-Key'
          expect(authenticator.valid_signature?).to be_falsy
        end

        it 'should fail on outdated request' do
          allow(Time).to receive(:now) { Time.new(2014, 11, 18, 0, 6) }
          expect(authenticator.valid_signature?).to be_falsy
        end

        it 'should compare signature otherwise' do
          expect(authenticator.valid_signature?).to be_truthy
        end
      end
    end
  end
end
