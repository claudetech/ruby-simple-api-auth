describe SimpleApiAuth do
  describe SimpleApiAuth::Config do
    let(:config) { SimpleApiAuth::Config.new }

    it 'should have default values' do
      expect(config.request_keys[:headers]).to eq(:headers)
      expect(config.request_keys[:http_verb]).to eq(:method)
    end

    it 'should be mutable' do
      config.request_keys[:headers] = :env
      expect(config.request_keys[:headers]).to eq(:env)
    end
  end
end
