describe SimpleApiAuth do
  it 'should be configurable' do
    expect(SimpleApiAuth.config.headers_name).to eq(:headers)
    SimpleApiAuth.configure do |config|
      config.headers_name = :env
    end
    expect(SimpleApiAuth.config.headers_name).to eq(:env)
  end
end
