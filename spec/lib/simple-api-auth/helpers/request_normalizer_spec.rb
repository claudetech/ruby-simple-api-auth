describe SimpleApiAuth do
  describe SimpleApiAuth::Helpers::RequestNormalizer do
    let(:normalizer) { SimpleApiAuth::Helpers::RequestNormalizer.new }

    describe '#normalize_headers' do
      let(:raw_headers) { mock_headers }
      let(:headers) { normalizer.normalize_headers(raw_headers) }

      it 'should normalize headers keys' do
        [:http_authorization, :http_x_saa_auth_time, :http_x_saa_key].each do |key|
          expect(headers).to include(key)
        end
        expect(headers.values).to eq(raw_headers.values)
      end
    end

    describe '#normalize' do
      it 'should symbolize keys' do
        expect(normalizer.normalize('foo')).to eq(:foo)
      end

      it 'should work with symbols' do
        expect(normalizer.normalize(:foo)).to eq(:foo)
      end

      it 'should downcase' do
        expect(normalizer.normalize('FOO')).to eq(:foo)
      end

      it 'should replace hyphens' do
        expect(normalizer.normalize('foo-bar')).to eq(:foo_bar)
      end

      it 'should work with more complex keys' do
        expect(normalizer.normalize('FOO-BAR-BAZ')).to eq(:foo_bar_baz)
      end
    end

    describe '#denormalize' do
      it 'should return capitalized underscored values' do
        expect(normalizer.denormalize(:foo_bar)).to eq('FOO_BAR')
      end
    end
  end
end
