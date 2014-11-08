describe SimpleApiAuth do
  describe SimpleApiAuth::Request do
    include SimpleApiAuth::Helpers::Request

    def check_request(request)
      expect(request.headers).to eq(normalize_headers(make_dummy_headers))
      expect(request.http_verb).to eq(:get)
    end

    describe '#initialize' do
      let(:request) { SimpleApiAuth::Request.new(rails_request) }

      it 'should set headers and http verb' do
        check_request(request)
      end
    end

    describe '#create' do
      context 'with third party requests' do
        requests.each do |name, request|
          before(:each) { request.configure }
          let(:dummy_request) { request.new(headers: make_dummy_headers, method: 'GET') }

          it "should create normalized request from #{name}" do
            normalized_request = SimpleApiAuth::Request.create(dummy_request)
            check_request(normalized_request)
          end
        end
      end

      it 'should not modify already normalized requests' do
        request = SimpleApiAuth::Request.new(rails_request)
        expect(SimpleApiAuth::Request.create(request).object_id).to eq(request.object_id)
      end
    end
  end
end
