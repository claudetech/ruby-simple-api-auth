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

  def self.extract_key(request)
    request = SimpleApiAuth::Request.create(request)
    request.headers[SimpleApiAuth.config.header_keys[:key]]
  end

  def self.valid_signature?(request, secret_key, options = {})
    authenticator = Authenticator.new(request, secret_key, options)
    authenticator.valid_signature?
  end

  def self.sign(request, secret_key, options = {})
    signer = SimpleApiAuth.config.signer.new(options)
    signer.sign(request, secret_key)
  end
end

ActiveRecord::Base.send(:extend, SimpleApiAuth::Authenticable) if defined?(ActiveRecord::Base)
