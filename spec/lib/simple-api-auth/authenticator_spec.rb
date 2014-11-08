describe SimpleApiAuth do
  describe SimpleApiAuth::Authenticator do
    include SimpleApiAuth::Helpers::Request

    let(:dummy_headers) { mock_headers }

    let(:authenticator) { SimpleApiAuth::Authenticator.new(dummy_request, mock_secret_key) }

    before(:each) do
      allow(Time).to receive(:now) { Time.new(2014, 11, 18, 0, 3) }
    end

    requests.each do |name, request|
      context "with #{name}" do
        before(:each) do
          request.configure
          setup_dummy_signer
        end
        let(:dummy_request) { request.new(headers: dummy_headers, method: 'GET') }

        describe '#valid_signature?' do
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
end
