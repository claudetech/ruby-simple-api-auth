helpers = Dir[File.expand_path('simple-api-auth/helpers/*.rb', File.dirname(__FILE__))]
files   = Dir[File.expand_path('simple-api-auth/*.rb', File.dirname(__FILE__))]
(helpers + files).each do |m|
  require m
end

module SimpleApiAuth
  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end
end
