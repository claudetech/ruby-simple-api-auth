describe SimpleApiAuth do
  describe SimpleApiAuth::Signer do

    let(:signer) { SimpleApiAuth::Signer.new }
    let(:request) { mock_request }

    describe '#make_hashed_request' do
      it 'should make a hased canonical request' do
        expect(signer.make_hashed_request(request)).to eq(mock_hashed_request)
      end

      it 'should encode payload' do
        request.body = StringIO.new('abc')
        expected = mock_hashed_request + '616263'
        expect(signer.make_hashed_request(request)).to eq(expected)
      end
    end

    describe '#make_string_to_sign' do
      it 'should generate correct string to sign' do
        expect(signer.make_string_to_sign(request)).to eq(mock_string_to_sign)
      end
    end

    describe '#sign' do
      let(:secret_key) { 'ultra_secret_key' }
      it 'should generate correct signature' do
        expect(signer.sign(request, secret_key)).to eq(mock_signature)
      end
    end
  end
end
