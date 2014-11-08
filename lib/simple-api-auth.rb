require 'open-uri'

['helpers/', '', 'hashers/'].each do |path|
  files = Dir[File.expand_path("simple-api-auth/#{path}*.rb", File.dirname(__FILE__))]
  files.each do |m|
    require m
  end
end

module SimpleApiAuth
  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end
end
