require 'codeclimate-test-reporter'
require 'coveralls'
CodeClimate::TestReporter.start
Coveralls.wear!

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')

require 'simple-api-auth'

support_glob = File.expand_path('support/**/*.rb', File.dirname(__FILE__))
Dir[support_glob].each { |f| require f }

RSpec.configure do |config|
  config.include SpecHelpers::Dummy
  config.extend SpecHelpers::Requests
  config.before(:each) do
    SimpleApiAuth.config.reset!
  end
end

class String
  def unindent
    first_line_spaces = self[/\A\s*/]
    gsub(/^#{first_line_spaces}/, '')
  end
end
