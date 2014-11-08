describe SimpleApiAuth do
  describe SimpleApiAuth::Request do
    include SimpleApiAuth::Helpers::Request

    let(:base_request) { SimpleApiAuth::Request.create(rails_request) }

    def check_request(request)
      expect(request.headers).to eq(normalize_headers(mock_headers))
      expect(request.http_verb).to eq(:get)
    end

    describe '#initialize' do
      let(:request) { SimpleApiAuth::Request.create(rails_request) }

      it 'should set headers and http verb' do
        check_request(request)
      end
    end

    describe '#create' do
      context 'with third party requests' do
        requests.each do |name, request|
          before(:each) { request.configure }
          let(:dummy_request) { request.new(headers: mock_headers, method: 'GET') }

          it "should create normalized request from #{name}" do
            normalized_request = SimpleApiAuth::Request.create(dummy_request)
            check_request(normalized_request)
          end
        end
      end

      it 'should not modify already normalized requests' do
        expect(SimpleApiAuth::Request.create(base_request).object_id).to eq(base_request.object_id)
      end
    end

    describe '#time' do
      it 'should return request time' do
        expect(base_request.time).to eq(request_time)
      end

      it 'should return nil on wrong time' do
        base_request.headers[:x_saa_auth_time] = 'foobar'
        expect(base_request.time).to be_nil
      end
    end
  end
end
