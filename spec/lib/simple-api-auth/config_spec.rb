describe SimpleApiAuth do
  describe SimpleApiAuth::Config do
    let(:config) { SimpleApiAuth::Config.new }

    it 'should have default values' do
      expect(config.headers_name).to eq(:headers)
      expect(config.http_verb_name).to eq(:method)
    end

    it 'should be mutable' do
      config.headers_name = :env
      expect(config.headers_name).to eq(:env)
    end
  end
end
