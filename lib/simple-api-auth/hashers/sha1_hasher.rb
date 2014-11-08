module SimpleApiAuth
  module Hasher
    class SHA1
      def hash(value)
        Digest::SHA1.digest(value)
      end

      def hmac(key, message)
        digest = OpenSSL::Digest.new('sha1')
        OpenSSL::HMAC.digest(digest, key, message)
      end
    end
  end
end
