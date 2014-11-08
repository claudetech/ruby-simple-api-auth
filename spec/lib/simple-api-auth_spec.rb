describe SimpleApiAuth do
  it 'should be configurable' do
    expect(SimpleApiAuth.config.request_keys[:headers]).to eq(:headers)
    SimpleApiAuth.configure do |config|
      config.request_keys[:headers] = :env
    end
    expect(SimpleApiAuth.config.request_keys[:headers]).to eq(:env)
  end
end
