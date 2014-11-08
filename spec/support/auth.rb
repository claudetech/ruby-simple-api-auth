module SpecHelpers
  module Auth
    class DummyHasher
      def hash(value)
        "hashed:#{value}"
      end

      def hmac(key, message)
        "#{key}:#{message}"
      end
    end
  end
end
