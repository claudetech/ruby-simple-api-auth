describe SimpleApiAuth do
  describe SimpleApiAuth::Request do

    let(:base_request) { SimpleApiAuth::Request.create(rails_request) }
    let(:normalizer) { SimpleApiAuth::Helpers::RequestNormalizer.new }

    def check_request(request)
      expect(request.headers).to eq(normalizer.normalize_headers(mock_headers))
      expect(request.http_verb).to eq(:get)
    end

    describe '#initialize' do
      let(:rails_req) { rails_request }
      let(:request) { SimpleApiAuth::Request.create(rails_req) }

      it 'should set headers and http verb' do
        check_request(request)
      end

      it 'should work with added headers' do
        rails_req.headers['RANDOM_HEADER'] = 'foobar'
        expect(request.headers).to include(:random_header)
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
        base_request.headers[:http_x_saa_auth_time] = 'foobar'
        expect(base_request.time).to be_nil
      end

      it 'should return nil on empty time' do
        base_request.headers.delete :http_x_saa_auth_time
        expect(base_request.time).to be_nil
      end
    end

    describe '#add_header' do
      let(:base_request) { rails_request }
      let(:request) { SimpleApiAuth::Request.create(base_request) }
      before(:each) { request.add_header(:http_foo_bar, 'foobar') }

      it 'should add header to request' do
        expect(request.headers[:http_foo_bar]).to eq('foobar')
      end

      it 'should add header to base request' do
        expect(base_request.headers['HTTP_FOO_BAR']).to eq('foobar')
      end
    end
  end
end
