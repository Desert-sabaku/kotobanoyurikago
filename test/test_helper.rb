ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "bcrypt"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

if defined?(ActionMailer::Base)
  # Disable actual email deliveries during tests. This prevents mail from being
  # sent and keeps test runs deterministic. Clear any existing deliveries so
  # tests start from a clean state.
  ActionMailer::Base.perform_deliveries = :test
  ActionMailer::Base.deliveries.clear if ActionMailer::Base.deliveries.respond_to?(:clear)
end
