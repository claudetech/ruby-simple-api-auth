describe SimpleApiAuth do
  it 'should be configurable' do
    expect(SimpleApiAuth.config.request_keys[:headers]).to eq(:headers)
    SimpleApiAuth.configure do |config|
      config.request_keys[:headers] = :env
    end
    expect(SimpleApiAuth.config.request_keys[:headers]).to eq(:env)
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
      SimpleApiAuth.config.header_keys[:key] = :key
      request.headers[:key] = request.headers.delete(:x_saa_key)
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
      request.headers[:authorization] = "Signature: #{mock_signature}"
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
            authorization: 'Signature: 7c171d095fd65b7078afd13a6b3bd4ecfe596552',
            x_saa_auth_time: request_time.iso8601,
            x_saa_key: 'wedontreallycarehere'
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

  describe '#sign' do
    let(:request) { mock_request }
    let(:base_secret) { 'a_very_secret_key' }
    let(:secret_key) { base_secret }
    let(:signature) { SimpleApiAuth.sign(request, secret_key) }

    it 'should return correct signature' do
      request.headers[:authorization] = "Signature: #{signature}"
      expect(SimpleApiAuth.valid_signature?(request, secret_key)).to be_truthy
    end

    context 'with a different key' do
      let(:secret_key) { 'another cool key' }
      it 'should not return the same signature' do
        request.headers[:authorization] = "Signature: #{signature}"
        expect(SimpleApiAuth.valid_signature?(request, base_secret)).to be_falsy
      end
    end
  end
end
