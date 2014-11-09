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

  def self.compute_signature(request, secret_key, options = {})
    request = SimpleApiAuth::Request.create(request)
    signer = SimpleApiAuth.config.signer.new(options)
    signer.sign(request, secret_key)
  end

  def self.sign!(request, secret_key, options = {})
    header_name = SimpleApiAuth.config.request_fields[:headers]
    request.send(header_name)[SimpleApiAuth.config.header_keys[:time]] = Time.now.utc.iso8601
    signature = compute_signature(request, secret_key, options)
    authorization_key = SimpleApiAuth.config.header_keys[:authorization]
    request.send(header_name)[authorization_key] = "Signature: #{signature}"
    request
  end
end

ActiveRecord::Base.send(:extend, SimpleApiAuth::Authenticable) if defined?(ActiveRecord::Base)
