glob = File.expand_path('simple-api-auth/**', File.dirname(__FILE__))
Dir[glob].each do |m|
  require File.expand_path(m, File.dirname(__FILE__))
end

module SimpleApiAuth
  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end
end
