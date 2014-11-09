module SimpleApiAuth
  module Authenticable
    def api_authenticable?
      false
    end

    def acts_as_api_authenticable(options = {})
      if api_authenticable?
        self.ssa_options = ssa_options.merge(options)
      else
        extend ClassMethods
        include InstanceMethods
        self.ssa_options = SimpleApiAuth.config.make_model_options(options)
        ssa_options[:auto_generate].each do |field|
          send(:after_initialize, "assign_#{field}")
        end
      end
    end

    module ClassMethods
      attr_accessor :ssa_options

      def api_authenticable?
        true
      end

      def ssa_authenticate(request)
        request = SimpleApiAuth::Request.create(request)
        entity = ssa_find(request)
        return false if entity.nil?
        secret_key = entity.send(ssa_options[:ssa_secret])
        return false unless SimpleApiAuth.valid_signature?(request, secret_key)
        entity
      end

      def ssa_find(request)
        key = SimpleApiAuth.extract_key(request)
        find_by(ssa_options[:ssa_key] => key)
      end

      def generate_ssa_key(options = {})
        length = options[:length] || (Math.log(count + 1, 64) + 5)
        loop do
          key = SecureRandom.urlsafe_base64(length)
          break key unless exists?(ssa_options[:ssa_key] => key)
        end
      end

      def generate_ssa_secret(options = {})
        length = options[:length] || 64
        SecureRandom.urlsafe_base64(length)
      end
    end

    module InstanceMethods
      def assign_ssa_key(options = {})
        assign_ssa(:ssa_key, options)
      end

      def assign_ssa_secret(options = {})
        assign_ssa(:ssa_secret, options)
      end

      private

      def assign_ssa(field, options = {})
        key_name = self.class.ssa_options[field]
        send("#{key_name}=", self.class.send("generate_#{field}", options))
      end
    end
  end
end
