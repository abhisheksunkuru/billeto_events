# spec/services/vote_service_spec.rb
require "rails_helper"

RSpec.describe VoteService do
  let(:event_store) { Rails.configuration.event_store }
  let(:service) { described_class.new(event_store: event_store) }
  let!(:event_record) { Event.create!(title: "Art Gallery Night", external_id: "ext_789") }
  let(:clerk_user_id) { "user_2testClerkId" }

  describe "#upvote" do
    it "publishes Events::EventUpvoted to the event stream with user_id" do
      service.upvote(event_id: event_record.id, user_id: clerk_user_id)

      # Read published events from the stream
      stream_events = event_store.read.stream("Event$#{event_record.id}").to_a
      published = stream_events.last

      expect(published).to be_a(Events::EventUpvoted)
      expect(published.data[:event_id]).to eq(event_record.id)
      expect(published.data[:user_id]).to eq(clerk_user_id)
      expect(published.data[:timestamp]).to be_present
    end

    it "updates the projection count in the database" do
      service.upvote(event_id: event_record.id, user_id: clerk_user_id)
      expect(event_record.reload.upvotes_count).to eq(1)
      expect(event_record.score).to eq(1)
    end
  end

  describe "#downvote" do
    it "publishes Events::EventDownvoted to the event stream with user_id" do
      service.downvote(event_id: event_record.id, user_id: clerk_user_id)

      stream_events = event_store.read.stream("Event$#{event_record.id}").to_a
      published = stream_events.last

      expect(published).to be_a(Events::EventDownvoted)
      expect(published.data[:event_id]).to eq(event_record.id)
      expect(published.data[:user_id]).to eq(clerk_user_id)
    end

    it "updates the read-model projection count in the database" do
      service.downvote(event_id: event_record.id, user_id: clerk_user_id)
      expect(event_record.reload.downvotes_count).to eq(1)
      expect(event_record.score).to eq(-1)
    end
  end
end