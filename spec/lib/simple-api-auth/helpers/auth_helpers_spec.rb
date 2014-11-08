describe SimpleApiAuth do
  describe SimpleApiAuth::Helpers::Auth do
    include SimpleApiAuth::Helpers::Request
    include SimpleApiAuth::Helpers::Auth

    let(:headers) { normalize_headers(make_dummy_headers) }

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
        expect(check_data(headers, :get)).to be_truthy
        expect(check_data(headers, :post)).to be_truthy
      end

      it 'should fail when http verb is not valid' do
        expect(check_data(headers, nil)).to be_falsy
        expect(check_data(headers, :forbidden_verb)).to be_falsy
      end

      it 'should fail when header is missing' do
        headers.delete :authorization
        expect(check_data(headers, :get)).to be_falsy
      end
    end

    describe '#too_old?' do
      it 'should allow recent enough requests' do
        allow(Time).to receive(:now) { Time.new(2014, 11, 18, 0, 3) }
        expect(too_old?(headers)).to be_falsy
      end

      it 'should reject old requests' do
        allow(Time).to receive(:now) { Time.new(2014, 11, 18, 0, 6) }
        expect(too_old?(headers)).to be_truthy
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
