module SimpleApiAuth
  class Request
    include SimpleApiAuth::Helpers::Request

    attr_accessor :headers, :http_verb
    def initialize(request)
      self.headers = normalize_headers(request.send(SimpleApiAuth.config.headers_name))
      self.http_verb = normalize(request.send(SimpleApiAuth.config.http_verb_name))
    end

    def self.create(request)
      if request.is_a?(Request)
        request
      else
        Request.new(request)
      end
    end
  end
end
