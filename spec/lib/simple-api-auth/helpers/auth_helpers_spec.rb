describe SimpleApiAuth do
  describe SimpleApiAuth::Helpers::Auth do
    include SimpleApiAuth::Helpers::Request
    include SimpleApiAuth::Helpers::Auth

    let(:headers) { normalize_headers(mock_headers) }
    let(:request) { SimpleApiAuth::Request.create(rails_request) }

    describe '#extract_signature' do
      it 'should return signature when present' do
        expect(extract_signature(headers)).to eq('dummy_signature')
      end

      it 'should return nil otherwise' do
        headers[:authorization] = 'Signatur: foobar'
        expect(extract_signature(headers)).to be_nil
      end
    end

    describe '#check_data' do
      it 'should return true when headers are present and http verb is valid' do
        expect(check_data(request)).to be_truthy
        request.http_verb = :post
        expect(check_data(request)).to be_truthy
      end

      it 'should fail when http verb is not valid' do
        request.http_verb = nil
        expect(check_data(request)).to be_falsy
        request.http_verb = :forbidden_verb
        expect(check_data(request)).to be_falsy
      end

      it 'should fail when header is missing' do
        request.headers.delete :authorization
        expect(check_data(request)).to be_falsy
      end
    end

    describe '#too_old?' do
      it 'should allow recent enough requests' do
        expect(too_old?(request)).to be_falsy
      end

      it 'should reject old requests' do
        request.headers[:x_saa_auth_time] = Time.new(2014, 11, 8).iso8601
        expect(too_old?(request)).to be_truthy
      end
    end

    describe '#secure_equals?' do
      it 'should succeed on equal values' do
        expect(secure_equals?('foo', 'foo', 'secret_key')).to be_truthy
      end

      it 'should fail on different values' do
        expect(secure_equals?('foo', 'bar', 'secret_key')).to be_falsy
      end
    end
  end
end
