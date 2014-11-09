class AuthenticableModel < ActiveRecord::Base
  acts_as_api_authenticable
end

class OverriddenAuthenticableModel < ActiveRecord::Base
  acts_as_api_authenticable ssa_key: :ssa_key, ssa_secret: :ssa_secret
  acts_as_api_authenticable ssa_key: :ssa_key, ssa_secret: :overriden_secret
end

class AuthenticableModelWithHooks < ActiveRecord::Base
  self.table_name = 'authenticable_models'
  acts_as_api_authenticable auto_generate: true
end
