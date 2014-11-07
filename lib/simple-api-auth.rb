%w{config version auth}.each do |m|
  require File.join(File.dirname(__FILE__), 'simple-api-auth', m)
end

module SimpleApiAuth
  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end
end
