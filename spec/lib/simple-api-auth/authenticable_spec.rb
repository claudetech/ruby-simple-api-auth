describe SimpleApiAuth do
  describe SimpleApiAuth::Authenticable do

    describe 'class extensions' do
      subject(:clazz) { AuthenticableModel }

      it { should respond_to(:ssa_options) }
      it { should respond_to(:ssa_authenticate) }
      it { should respond_to(:ssa_find) }

      it 'should set options' do
        expect(clazz.ssa_options[:ssa_key]).to eq(:ssa_key)
        expect(clazz.ssa_options[:ssa_secret]).to eq(:ssa_secret)
      end

      context 'when included several times' do
        subject(:clazz) { OverriddenAuthenticableModel }

        it { should respond_to(:ssa_options) }
        it 'should have overriden attributes' do
          expect(clazz.ssa_options[:ssa_secret]).to eq(:overriden_secret)
        end
      end

      describe '#ssa_find' do
        let(:request) { mock_request }

        subject { clazz.ssa_find(request) }

        it 'should return nil when not found' do
          expect(subject).to be_nil
        end

        it 'should return entity when present' do
          entity = AuthenticableModel.create(ssa_key: 'user_personal_key')
          expect(subject.id).to eq(entity.id)
        end
      end

      describe '#ssa_authenticate' do
        let(:request) { mock_request }
        before(:each) do
          request.headers[:authorization] = "Signature: #{mock_signature}"
        end

        subject { clazz.ssa_authenticate(request) }

        it 'should return false when the entity does not exists' do
          expect(subject).to be false
        end

        it 'should return false when the secret key does not match' do
          clazz.create(ssa_key: 'user_personal_key', ssa_secret: 'something else')
          expect(subject).to be false
        end

        it 'should return the resource when signature matches' do
          entity = clazz.create(
            ssa_key: 'user_personal_key', ssa_secret: 'ultra_secret_key')
          expect(subject.id).to eq(entity.id)
        end
      end

      { 'generate_ssa_key' => 5, 'generate_ssa_secret' => 64 }.each do |method, value|
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
        subject { AuthenticableModelWithHooks.new }
        its(:ssa_key) { should_not be_nil }
        its(:ssa_secret) { should_not be_nil }
      end
    end

    describe 'instance extension' do
      subject(:model) { AuthenticableModel.new }

      it { should respond_to(:assign_ssa_key) }
      it { should respond_to(:assign_ssa_secret) }
      its(:ssa_key) { should be_nil }
      its(:ssa_secret) { should be_nil }

      [:assign_ssa_key, :assign_ssa_secret].each do |method|
        field_name = method.to_s.gsub('assign_', '')
        describe "##{method}" do
          it "should assign #{field_name}" do
            expect(model.send(field_name)).to be_nil
            model.send(method)
            expect(model.send(field_name)).not_to be_nil
          end
        end
      end
    end
  end
end
