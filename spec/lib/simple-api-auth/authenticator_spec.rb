describe SimpleApiAuth do
  describe SimpleApiAuth::Authenticator do

    let(:dummy_headers) { mock_headers }

    let(:authenticator) { SimpleApiAuth::Authenticator.new(dummy_request, mock_secret_key) }

    requests.each do |name, request|
      context "with #{name}" do
        before(:each) do
          request.configure
          setup_dummy_signer
        end
        let(:dummy_request) { request.new(headers: dummy_headers, method: 'GET') }

        describe '#valid_signature?' do
          it 'should fail on missing header' do
            dummy_headers.delete 'HTTP_X_SAA_KEY'
            expect(authenticator.valid_signature?).to be_falsy
          end

          it 'should fail on outdated request' do
            dummy_headers[:http_x_saa_auth_time] = outdated_time.iso8601
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
