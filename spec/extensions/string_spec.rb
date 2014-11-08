describe String do
  describe '#hexdecode' do
    it 'should decode text' do
      expect(Digest.hexencode('foo').hexdecode).to eq('foo')
    end

    it 'should decode binary' do
      digest = OpenSSL::Digest.new('sha1')
      binary_data = OpenSSL::HMAC.digest(digest, 'foo', 'bar')
      expect(Digest.hexencode(binary_data).hexdecode).to eq(binary_data)
    end
  end
end
