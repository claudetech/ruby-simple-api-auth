class AuthenticableModel < ActiveRecord::Base
  acts_as_api_authenticable
end

class OverriddenAuthenticableModel < ActiveRecord::Base
  acts_as_api_authenticable saa_key: :saa_key, saa_secret: :saa_secret
  acts_as_api_authenticable saa_key: :saa_key, saa_secret: :overriden_secret
end

class AuthenticableModelWithHooks < ActiveRecord::Base
  self.table_name = 'authenticable_models'
  acts_as_api_authenticable auto_generate: true
end
