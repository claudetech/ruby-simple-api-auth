database_yml = File.expand_path('../../internal/config/database.yml', __FILE__)
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), '../debug.log'))
ActiveRecord::Base.logger.level = ENV['TRAVIS'] ? ::Logger::ERROR : ::Logger::DEBUG
ActiveRecord::Base.configurations = YAML.load_file(database_yml)

begin
  ActiveRecord::Base.establish_connection(:test)
rescue
  ActiveRecord::Base.establish_connection('test')
end

load(File.dirname(__FILE__) + '/../internal/db/schema.rb')
load(File.dirname(__FILE__) + '/../internal/app/models/models.rb')
