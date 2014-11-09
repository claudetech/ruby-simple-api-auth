module SimpleApiAuth
  module Authenticable
    def acts_as_api_authenticable(options = {})
      if respond_to?(:ssa_authenticate)
        self.ssa_options = ssa_options.merge(options)
      else
        cattr_accessor :ssa_options
        options = SimpleApiAuth.config.model_defaults.merge(options)
        self.ssa_options = options
        extend ClassMethods
      end
    end

    module ClassMethods
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
    end
  end
end
