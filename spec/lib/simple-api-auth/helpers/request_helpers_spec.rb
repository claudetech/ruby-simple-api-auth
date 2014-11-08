describe SimpleApiAuth do
  describe SimpleApiAuth::Helpers::Request do
    include SimpleApiAuth::Helpers::Request

    describe '#normalize_headers' do
      let(:raw_headers) { mock_headers }
      let(:headers) { normalize_headers(raw_headers) }

      it 'should normalize headers keys' do
        [:authorization, :x_saa_auth_time, :x_saa_key].each do |key|
          expect(headers).to include(key)
        end
        expect(headers.values).to eq(raw_headers.values)
      end
    end

    describe '#normalize' do
      it 'should symbolize keys' do
        expect(normalize('foo')).to eq(:foo)
      end

      it 'should work with symbols' do
        expect(normalize(:foo)).to eq(:foo)
      end

      it 'should downcase' do
        expect(normalize('FOO')).to eq(:foo)
      end

      it 'should replace hyphens' do
        expect(normalize('foo-bar')).to eq(:foo_bar)
      end

      it 'should work with more complex keys' do
        expect(normalize('FOO-BAR-BAZ')).to eq(:foo_bar_baz)
      end
    end
  end
end
