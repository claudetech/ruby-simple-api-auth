class AuthenticableModel < ActiveRecord::Base
  acts_as_api_authenticable ssa_key: :ssa_key, ssa_secret: :ssa_secret
end

class OverriddenAuthenticableModel < ActiveRecord::Base
  acts_as_api_authenticable ssa_key: :ssa_key, ssa_secret: :ssa_secret
  acts_as_api_authenticable ssa_key: :ssa_key, ssa_secret: :overriden_secret
end
