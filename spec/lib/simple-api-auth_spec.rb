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

  describe '#valid_signature?' do
    let(:request) { mock_request }

    it 'should fail with wrong request' do
      result = SimpleApiAuth.valid_signature?(request, mock_secret_key)
      expect(result).to be_falsy
    end

    it 'should succeed with correct signature' do
      request.headers[:authorization] = "Signature: #{mock_signature}"
      result = SimpleApiAuth.valid_signature?(request, mock_secret_key)
      expect(result).to be_truthy
    end

    context 'with real world example' do
      before(:each) do
      end
    end
  end
end
