# config/initializers/rails_event_store.rb
Rails.application.configure do
  config.to_prepare do
    Rails.configuration.event_store = RailsEventStore::JSONClient.new

    Rails.configuration.event_store.tap do |store|
      store.subscribe(Projections::EventVotesCounter.new, to: [
        Events::EventUpvoted,
        Events::EventDownvoted
      ])
    end
  end
end