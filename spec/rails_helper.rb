# spec/rails_helper.rb
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "capybara/rspec"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Clear event store streams between tests
  config.before(:each) do
    Rails.configuration.event_store = RailsEventStore::JSONClient.new

    # Re-subscribe projection
    Rails.configuration.event_store.subscribe(Projections::EventVotesCounter.new, to: [
      Events::EventUpvoted,
      Events::EventDownvoted
    ])
  end
end