require 'byebug'
require 'fedora-migrate'
require 'equivalent-xml/rspec_matchers'
require 'support/example_model'
ENV['environment'] = "test"

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
  # TODO: Blacklight not getting its configuration
  config.before(:each) do
    ActiveFedora::Base.delete_all
    #RSolr.connect.delete_by_query("*:*")
    #RSolr.connect.commit
  end

  config.order = :random

  config.include ExampleModel

end

def load_fixture file
  File.open("spec/fixtures/datastreams/#{file}")
end
