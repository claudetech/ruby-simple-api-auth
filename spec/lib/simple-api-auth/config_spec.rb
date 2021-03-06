describe SimpleApiAuth do
  describe SimpleApiAuth::Config do
    let(:config) { SimpleApiAuth::Config.new }

    it 'should have default values' do
      expect(config.request_fields[:headers]).to eq(:headers)
      expect(config.request_fields[:http_verb]).to eq(:method)
    end

    it 'should be mutable' do
      config.request_fields[:headers] = :env
      expect(config.request_fields[:headers]).to eq(:env)
    end

    describe 'make_model_options' do
      let(:model_options) { { saa_key: :foobar } }
      subject(:options) { config.make_model_options(model_options) }

      it 'should merge options' do
        expect(options[:saa_key]).to eq(:foobar)
        expect(options[:saa_secret]).to eq(:saa_secret)
        expect(options[:auto_generate]).to eq([])
      end

      describe 'auto_generate configuration' do
        it 'should handle symbol' do
          model_options[:auto_generate] = :saa_key
          expect(options[:auto_generate]).to eq([:saa_key])
        end

        it 'should handle true' do
          model_options[:auto_generate] = true
          expect(options[:auto_generate]).to eq([:saa_key, :saa_secret])
        end

        it 'should handle false' do
          model_options[:auto_generate] = false
          expect(options[:auto_generate]).to eq([])
        end

        it 'should handle arrays' do
          model_options[:auto_generate] = [:saa_secret]
          expect(options[:auto_generate]).to eq([:saa_secret])
        end
      end
    end
  end
end
