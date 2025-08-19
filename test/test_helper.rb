require 'minitest/autorun'
require 'rack/test'
require 'rack'
require 'digest/sha1'
require 'rack/request'
require 'database_cleaner'

# Configure DatabaseCleaner
DatabaseCleaner.strategy = :transaction

class Minitest::Test
  def before_setup
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
  end
end
