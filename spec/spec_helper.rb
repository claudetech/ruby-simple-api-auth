require 'coveralls'
require 'codeclimate-test-reporter'
Coveralls.wear!
CodeClimate::TestReporter.start

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter,
  CodeClimate::TestReporter::Formatter
]

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')

require 'active_record'
require 'database_cleaner'
require 'simple-api-auth'
require 'rspec/its'

support_glob = File.expand_path('support/**/*.rb', File.dirname(__FILE__))
Dir[support_glob].each { |f| require f }

RSpec.configure do |config|
  config.include SpecHelpers::Dummy
  config.extend SpecHelpers::Requests

  config.before(:each) do
    allow(Time).to receive(:now) { Time.utc(2014, 11, 8, 0, 7) }
    SimpleApiAuth.config.reset!
    SimpleApiAuth.config.hasher = SpecHelpers::Auth::DummyHasher
  end
end
