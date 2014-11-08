describe SimpleApiAuth do
  describe SimpleApiAuth::Signer do
    before(:each) do
      SimpleApiAuth.config.hasher = SpecHelpers::Auth::DummyHasher
    end

    let(:signer) { SimpleApiAuth::Signer.new }
    let(:request) { SimpleApiAuth::Request.create(rails_request) }

    let(:base_hashed_request) do
      <<-EOF.unindent[0..-2]
        hashed
        get
        /foobar
        foo=bar&baz=qux

      EOF
    end

    let(:string_to_sign) { request.headers[:x_saa_auth_time] + "\n" + base_hashed_request }

    describe '#make_hashed_request' do
      it 'should make a hased canonical request' do
        expect(signer.make_hashed_request(request)).to eq(base_hashed_request)
      end

      it 'should encode payload' do
        request.body = StringIO.new('abc')
        expected = base_hashed_request + '616263'
        expect(signer.make_hashed_request(request)).to eq(expected)
      end
    end

    describe '#make_string_to_sign' do
      it 'should generate correct string to sign' do
        expect(signer.make_string_to_sign(request)).to eq(string_to_sign)
      end
    end

    describe '#sign' do
      let(:secret_key) { 'ultra_secret_key' }
      it 'should generate correct signature' do
        date = request.time.strftime('%Y%m%d')
        expected = "ssa#{secret_key}\n#{date}\nssa_request"
        allow(Digest).to receive(:hexencode) { |v| v }
        expect(signer.sign(request, secret_key)).to eq(expected)
      end
    end
  end
end
