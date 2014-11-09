require 'open-uri'

['extensions/', 'helpers/', '', 'hashers/'].each do |path|
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

  def self.log(severity, message = nil, progname = nil, &block)
    config.logger.log(severity, message, progname, &block) unless config.logger.nil?
  end
end

ActiveRecord::Base.send(:extend, SimpleApiAuth::Authenticable) if defined?(ActiveRecord::Base)
