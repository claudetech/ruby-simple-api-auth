module SpecHelpers
  module Auth
    class DummyHasher
      def hash(value)
        "hashed\n#{value}"
      end

      def hmac(key, message)
        "#{key}\n#{message}"
      end
    end
  end
end
