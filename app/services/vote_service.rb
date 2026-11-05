# app/services/vote_service.rb
class VoteService
  def initialize(event_store: Rails.configuration.event_store)
    @event_store = event_store
  end

  def upvote(event_id:, user_id: )
    publish_vote(Events::EventUpvoted, event_id, user_id)
  end

  def downvote(event_id:, user_id: )
    publish_vote(Events::EventDownvoted, event_id, user_id)
  end

  private

  def publish_vote(event_class, event_id, user_id)
    stream_name = "Event$#{event_id}"
    event = event_class.new(data: { event_id: event_id, user_id: user_id, timestamp: Time.current })

    @event_store.publish(event, stream_name: stream_name)
  end
end