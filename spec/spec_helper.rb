require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')

require 'simple-api-auth'

support_glob = File.expand_path('support/**/*.rb', File.dirname(__FILE__))
Dir[support_glob].each { |f| require f }

RSpec.configure do |config|
  config.include SpecHelpers::Dummy
  config.before(:each) do
    SimpleApiAuth.config.reset!
  end
end
