# spec/system/voting_flow_spec.rb
require "rails_helper"

RSpec.describe "Voting and Authentication Flow", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let!(:event) do
    Event.create!(
      title: "Summer Music Festival",
      external_id: "billetto_fest_1",
      start_date: 1.week.from_now,
      description: "Live outdoor music festival."
    )
  end

  context "when visitor is not logged in" do
    it "displays the event and shows login prompt when attempting to vote" do
      visit root_path

      expect(page).to have_content("Summer Music Festival")
      expect(page).to have_content("Total Votes: 0")

      # Attempt to vote
      within("#event-#{event.id}") do
        click_button "▲ Upvote"
      end

      # Expect redirect / warning banner
      expect(page).to have_content("Please sign in to vote.")
      expect(page).to have_content("Total Votes: 0")
    end
  end

  context "when user is signed in" do
    before do
      # Simulate Clerk authentication cookie by injecting a stubbed token
      allow_any_instance_of(ApplicationController)
        .to receive(:current_user_id)
        .and_return("user_browser_clerk_1")
    end

    it "allows the user to upvote and immediately updates the vote count on the page" do
      visit root_path

      within("#event-#{event.id}") do
        expect(page).to have_content("Total Votes: 0")
        click_button "▲ Upvote"
      end

      expect(page).to have_content("Total Votes: 1")
    end

    it "allows the user to downvote and reflects in the vote score" do
      visit root_path

      within("#event-#{event.id}") do
        click_button "▼ Downvote"
      end

      expect(page).to have_content("Total Votes: -1")
    end
  end

  describe "Authentication flow UI presence" do
    it "renders Clerk sign-in and sign-up buttons for visitors" do
      visit root_path

      expect(page).to have_selector("#sign-in-btn", text: "Sign In")
      expect(page).to have_selector("#sign-up-btn", text: "Sign Up")
    end

    it "blocks unauthenticated voting and prompts to sign in" do
      visit root_path

      within("#event-#{event.id}") do
        click_button "▲ Upvote"
      end

      expect(page).to have_content("Please sign in to vote.")
      expect(event.reload.upvotes_count).to eq(0)
    end
  end

  describe "Authenticated voting & logout session lifecycle" do
    it "allows an authenticated user to vote, reflects counts, and handles logout" do
      # 1. Simulate active Clerk user session
      allow_any_instance_of(ApplicationController)
        .to receive(:current_user_id)
        .and_return("user_2clerk_e2e_tester")

      visit root_path

      # 2. Vote as authenticated user
      within("#event-#{event.id}") do
        click_button "▲ Upvote"
      end
      expect(page).to have_content("Total Votes: 1")

      # 3. Simulate user signing out
      allow_any_instance_of(ApplicationController)
        .to receive(:current_user_id)
        .and_return(nil)

      visit root_path

      # 4. Attempting to vote again is prevented
      within("#event-#{event.id}") do
        click_button "▼ Downvote"
      end
      expect(page).to have_content("Please sign in to vote.")
    end
  end
end