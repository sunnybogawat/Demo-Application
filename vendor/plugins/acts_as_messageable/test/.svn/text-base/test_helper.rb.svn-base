$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/fixtures')
$:.unshift(File.dirname(__FILE__) + '/lib')

require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/fixtures'
require 'test/unit'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__)+'/../../../..'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))
Rails.env = 'test'
require 'rails/test_help'

class ActiveSupport::TestCase
    include ActiveRecord::TestFixtures
    self.fixture_path = File.expand_path(File.dirname(__FILE__) + '/fixtures')
    self.use_instantiated_fixtures  = false
    self.use_transactional_fixtures = true
  end

#ActiveSupport::TestCase.fixture_path = File.expand_path(File.dirname(__FILE__) + '/fixtures')

def load_schema
  config = YAML::load(IO.read(File.dirname(__FILE__) + '/db/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
  db_adapter = ENV['DB'] || 'mysql'

  if db_adapter.nil?
    raise "No DB Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3."
  end

  ActiveRecord::Base.establish_connection(config[db_adapter])
  load(File.dirname(__FILE__) + "/db/schema.rb")
  require File.expand_path(File.dirname(__FILE__) + '/../init.rb')
end
