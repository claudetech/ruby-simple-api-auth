describe SimpleApiAuth do
  describe SimpleApiAuth::Authenticable do

    describe 'class extensions' do
      subject(:clazz) { AuthenticableModel }

      it { should respond_to(:saa_options) }
      it { should respond_to(:saa_authenticate) }
      it { should respond_to(:saa_find) }

      it 'should set options' do
        expect(clazz.saa_options[:saa_key]).to eq(:saa_key)
        expect(clazz.saa_options[:saa_secret]).to eq(:saa_secret)
      end

      context 'when included several times' do
        subject(:clazz) { OverriddenAuthenticableModel }

        it { should respond_to(:saa_options) }
        it 'should have overriden attributes' do
          expect(clazz.saa_options[:saa_secret]).to eq(:overriden_secret)
        end
      end

      describe '#saa_find' do
        let(:request) { mock_request }

        subject { clazz.saa_find(request) }

        it 'should return nil when not found' do
          expect(subject).to be_nil
        end

        it 'should return entity when present' do
          entity = AuthenticableModel.create(saa_key: 'user_personal_key')
          expect(subject.id).to eq(entity.id)
        end
      end

      describe '#saa_authenticate' do
        let(:request) { mock_request }
        before(:each) do
          request.headers[:http_authorization] = "Signature: #{mock_signature}"
        end

        subject { clazz.saa_authenticate(request) }

        it 'should return false when the entity does not exists' do
          expect(subject).to be false
        end

        it 'should return false when the secret key does not match' do
          clazz.create(saa_key: 'user_personal_key', saa_secret: 'something else')
          expect(subject).to be false
        end

        it 'should return the resource when signature matches' do
          entity = clazz.create(
            saa_key: 'user_personal_key', saa_secret: 'ultra_secret_key')
          expect(subject.id).to eq(entity.id)
        end
      end

      { 'generate_saa_key' => 5, 'generate_saa_secret' => 64 }.each do |method, value|
        describe "##{method}" do
          let(:options) { {} }
          let(:key) { clazz.send(method.to_sym, options) }
          it 'should generate a long enough key' do
            expect(key.length).to be > value
          end

          it 'should use options length' do
            options[:length] = 1
            expect(key.length).to be < 3
          end
        end
      end

      describe 'hooks' do
        subject(:model) { AuthenticableModelWithHooks.create }
        its(:saa_key) { should_not be_nil }
        its(:saa_secret) { should_not be_nil }

        context 'with existing model' do
          subject { AuthenticableModelWithHooks.find(model.id) }
          it 'should not override keys' do
            expect(subject.saa_key).to eq(model.saa_key)
            expect(subject.saa_secret).to eq(model.saa_secret)
          end
        end

      end
    end

    describe 'instance extension' do
      subject(:model) { AuthenticableModel.new }

      it { should respond_to(:assign_saa_key) }
      it { should respond_to(:assign_saa_secret) }
      its(:saa_key) { should be_nil }
      its(:saa_secret) { should be_nil }

      [:assign_saa_key, :assign_saa_secret].each do |method|
        field_name = method.to_s.gsub('assign_', '')
        describe "##{method}" do
          it "should assign #{field_name}" do
            expect(model.send(field_name)).to be_nil
            model.send(method)
            expect(model.send(field_name)).not_to be_nil
          end
        end
      end

      describe '#saa_sign!' do
        let!(:model) { AuthenticableModelWithHooks.create }
        let(:request) { mock_request }
        before(:each) { model.saa_sign!(request) }

        it 'should add time headers' do
          expect(request.headers[:http_x_saa_auth_time]).not_to be_nil
        end

        it 'should add key header' do
          expect(request.headers[:http_x_saa_key]).to eq(model.saa_key)
        end

        it 'should add authorization' do
          expect(request.headers[:http_authorization]).not_to be_nil
          expected = "Signature: #{SimpleApiAuth.compute_signature(request, model.saa_secret)}"
          expect(request.headers[:http_authorization]).to eq(expected)
        end

        it 'should sign request' do
          fetched = AuthenticableModelWithHooks.saa_authenticate(request)
          expect(fetched).not_to be_falsy
          expect(fetched.id).to eq(model.id)
        end
      end
    end
  end
end
