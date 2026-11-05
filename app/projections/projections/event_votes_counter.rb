# app/projections/projections/event_votes_counter.rb
module Projections
  class EventVotesCounter
    def call(event)
      event_id = event.data.fetch(:event_id)
      record = Event.find(event_id)

      case event
      when Events::EventUpvoted
        record.increment!(:upvotes_count)
      when Events::EventDownvoted
        record.increment!(:downvotes_count)
      end
    end
  end
end