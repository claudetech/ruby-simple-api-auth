describe SimpleApiAuth do
  it 'should be configurable' do
    expect(SimpleApiAuth.config.request_fields[:headers]).to eq(:headers)
    SimpleApiAuth.configure do |config|
      config.request_fields[:headers] = :env
    end
    expect(SimpleApiAuth.config.request_fields[:headers]).to eq(:env)
  end

  describe '#log' do
    it 'should not fail on nil' do
      SimpleApiAuth.log('foobar')
    end

    it 'should log when logger is present' do
      s = StringIO.new('', 'a')
      SimpleApiAuth.config.logger = Logger.new(s)
      expect(s.string).not_to include('foobar')
      SimpleApiAuth.log(Logger::WARN, 'foobar')
      expect(s.string).to include('foobar')
    end
  end

  describe '#extract_key' do
    let(:request) { mock_request }
    subject { SimpleApiAuth.extract_key(request) }

    it 'should extract correct key' do
      expect(subject).to eq('user_personal_key')
    end

    it 'should work with custom headers' do
      SimpleApiAuth.config.header_keys[:saa_key] = :key
      request.headers[:key] = request.headers.delete(:http_x_saa_key)
      expect(subject).to eq('user_personal_key')
    end
  end

  describe '#valid_signature?' do
    let(:request) { mock_request }
    let(:result) { SimpleApiAuth.valid_signature?(request, mock_secret_key) }

    it 'should fail with wrong request' do
      expect(result).to be_falsy
    end

    it 'should succeed with correct signature' do
      request.headers[:http_authorization] = "Signature: #{mock_signature}"
      expect(result).to be_truthy
    end

    context 'with real world example' do
      before(:each) do
        SimpleApiAuth.config.hasher = SimpleApiAuth::Hasher::SHA1
      end
      let(:request) do
        SimpleApiAuth::Request.new(
          http_verb: 'GET',
          uri: '/foo/bar',
          query_string: 'foo=bar&bar=qux',
          body: StringIO.new('somerandombody'),
          headers: {
            http_authorization: 'Signature: 6990ae83450457f6e1ca4a64b078751b12e8d429',
            http_x_saa_auth_time: request_time.iso8601,
            http_x_saa_key: 'wedontreallycarehere'
          }
        )
      end

      it 'should succeed with correct key' do
        expect(SimpleApiAuth.valid_signature?(request, mock_secret_key)).to be_truthy
      end

      it 'should fail with wrong key' do
        expect(SimpleApiAuth.valid_signature?(request, 'somerandomkey')).to be_falsy
      end
    end
  end

  describe 'signing methods' do
    let(:request) { mock_request }
    let(:base_secret) { 'a_very_secret_key' }
    let(:secret_key) { base_secret }
    subject { SimpleApiAuth.valid_signature?(request, secret_key) }

    describe '#compute_signature' do
      let(:signature) { SimpleApiAuth.compute_signature(request, secret_key) }

      it 'should return correct signature' do
        request.headers[:http_authorization] = "Signature: #{signature}"
        expect(subject).to be_truthy
      end

      context 'with a different key' do
        let(:secret_key) { 'another cool key' }
        it 'should not return the same signature' do
          request.headers[:http_authorization] = "Signature: #{signature}"
          expect(SimpleApiAuth.valid_signature?(request, base_secret)).to be_falsy
        end
      end
    end

    describe '#sign!' do
      it 'should sign the current request' do
        SimpleApiAuth.sign!(request, secret_key)
        expect(subject).to be_truthy
      end

      it 'should add time header' do
        request.headers.delete 'HTTP_X_SAA_AUTH_TIME'
        SimpleApiAuth.sign!(request, secret_key)
        expect(subject).to be_truthy
        expect(request.headers[:http_x_saa_auth_time]).not_to be_nil
      end

      describe 'with rails request' do
        let(:request) { rails_request }

        it 'should work' do
          SimpleApiAuth.sign!(request, secret_key)
          expect(subject).to be_truthy
        end

        it 'should add headers with prefix' do
          request.headers.delete 'HTTP_X_SAA_AUTH_TIME'
          SimpleApiAuth.sign!(request, secret_key)
          expect(subject).to be_truthy
          expect(request.headers['HTTP_X_SAA_AUTH_TIME']).not_to be_nil
        end
      end
    end
  end
end
