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
          AuthenticableModel.create(ssa_key: 'user_personal_key', ssa_secret: 'something else')
          expect(subject).to be false
        end

        it 'should return the resource when signature matches' do
          entity = AuthenticableModel.create(
            ssa_key: 'user_personal_key', ssa_secret: 'ultra_secret_key')
          expect(subject.id).to eq(entity.id)
        end
      end
    end

    describe 'instance extension' do
      subject { AuthenticableModel.new }
    end
  end
end
