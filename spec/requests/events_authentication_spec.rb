# spec/requests/events_authentication_spec.rb
require "rails_helper"

RSpec.describe "Events Voting Authentication", type: :request do
  let!(:event) { Event.create!(title: "Outdoor Concert", external_id: "ext_456") }

  context "when user is unauthenticated" do
    it "redirects upvote to root with an alert" do
      post upvote_event_path(event)

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Please sign in to vote.")
      expect(event.reload.upvotes_count).to eq(0)
    end

    it "redirects downvote to root with an alert" do
      post downvote_event_path(event)

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Please sign in to vote.")
      expect(event.reload.downvotes_count).to eq(0)
    end
  end

  context "when user is authenticated via Clerk" do
    before do
      # Stub the authentication helper in ApplicationController
      allow_any_instance_of(ApplicationController)
        .to receive(:current_user_id)
        .and_return("user_clerk_test_99")
    end

    it "permits voting and redirects back to events index" do
      post upvote_event_path(event)

      expect(response).to redirect_to(events_path)
      expect(event.reload.upvotes_count).to eq(1)
    end
  end
end