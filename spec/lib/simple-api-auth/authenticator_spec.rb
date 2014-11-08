describe SimpleApiAuth do
  describe SimpleApiAuth::Authenticator do

    let(:dummy_headers) do
      {
        'Authorization' => 'Signature dummy',
        'X-Saa-Auth-Time' => Time.new(2014, 11, 18).iso8601,
        'X-Saa-Key' => 'user_personal_key'
      }
    end
    let(:dummy_resource) { SpecHelpers::Dummy::Resource.new('dummy_key', 'dummy_token') }
    let(:dummy_request) { SpecHelpers::Dummy::RailsRequest.new(dummy_headers, 'GET') }
    let(:authenticator) { SimpleApiAuth::Authenticator.new(dummy_resource, dummy_request) }

    it 'should set verb' do
      expect(authenticator.http_verb).to eq(:get)
    end

    it 'should set headers' do
      [:authorization, :x_saa_auth_time, :x_saa_key].each do |key|
        expect(authenticator.headers).to include(key)
      end
      expect(authenticator.headers.values).to eq(dummy_headers.values)
    end

    it 'should return false on missing header' do
      dummy_headers.delete 'X-Saa-Key'
      puts authenticator.headers
    end
  end
end
