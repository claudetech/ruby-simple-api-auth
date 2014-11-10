module SimpleApiAuth
  module Authenticable
    def api_authenticable?
      false
    end

    def acts_as_api_authenticable(options = {})
      if api_authenticable?
        self.saa_options = saa_options.merge(options)
      else
        extend ClassMethods
        include InstanceMethods
        self.saa_options = SimpleApiAuth.config.make_model_options(options)
        saa_options[:auto_generate].each do |field|
          send(:after_initialize, "assign_#{field}")
        end
      end
    end

    module ClassMethods
      attr_accessor :saa_options

      def api_authenticable?
        true
      end

      def saa_authenticate(request)
        request = SimpleApiAuth::Request.create(request)
        entity = saa_find(request)
        return false if entity.nil?
        secret_key = entity.send(saa_options[:saa_secret])
        return false unless SimpleApiAuth.valid_signature?(request, secret_key)
        entity
      end

      def saa_find(request)
        key = SimpleApiAuth.extract_key(request)
        find_by(saa_options[:saa_key] => key)
      end

      def generate_saa_key(options = {})
        length = options[:length] || (Math.log(count + 1, 64) + 5)
        loop do
          key = SecureRandom.urlsafe_base64(length)
          break key unless exists?(saa_options[:saa_key] => key)
        end
      end

      def generate_saa_secret(options = {})
        length = options[:length] || 64
        SecureRandom.urlsafe_base64(length)
      end
    end

    module InstanceMethods
      def assign_saa_key(options = {})
        assign_saa(:saa_key, options)
      end

      def assign_saa_secret(options = {})
        assign_saa(:saa_secret, options)
      end

      def saa_sign!(request)
        request = SimpleApiAuth::Request.create(request)
        key = send(self.class.saa_options[:saa_key])
        request.add_header(SimpleApiAuth.config.header_keys[:saa_key], key)
        SimpleApiAuth.sign!(request, send(self.class.saa_options[:saa_secret]))
      end

      private

      def assign_saa(field, options = {})
        return unless new_record? || options[:force]
        key_name = self.class.saa_options[field]
        send("#{key_name}=", self.class.send("generate_#{field}", options))
      end
    end
  end
end
