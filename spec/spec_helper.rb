require 'byebug' unless ENV['TRAVIS']
ENV['RAILS_ENV'] = "test"

require 'fedora-migrate'
require 'equivalent-xml/rspec_matchers'
require 'support/example_model'
require 'active_fedora/cleaner'

require 'http_logger'
ActiveFedora::Base.logger = Logger.new(STDERR)
ActiveFedora::Base.logger.level = Logger::WARN

# HttpLogger.logger = Logger.new(STDOUT)
# HttpLogger.ignore = [/(127\.0\.0\.1|localhost):8983\/solr/]
# HttpLogger.colorize = false
# HttpLogger.log_headers = true

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # Have a clean slate for every test
  config.before(:each) do
    ActiveFedora::Cleaner.clean!
    ActiveFedora::SolrService.instance.conn.delete_by_query('*:*', params: { 'softCommit' => true })
    FileUtils.rm_rf(FedoraMigrate::MigrationReport::DEFAULT_PATH)
  end

  config.order = :random

  config.include ExampleModel
end

def load_fixture(file)
  File.open("spec/fixtures/datastreams/#{file}")
end
