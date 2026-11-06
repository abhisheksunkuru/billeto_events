# spec/models/event_spec.rb
require "rails_helper"

RSpec.describe Event, type: :model do
  describe "validations" do
    subject {
      described_class.new(
        title: "Copenhagen Tech Meetup",
        external_id: "ext_billetto_123",
        start_date: 2.days.from_now,
        end_date: 3.days.from_now
      )
    }

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is invalid without a title" do
      subject.title = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:title]).to include("can't be blank")
    end

    it "is invalid without an external_id" do
      subject.external_id = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:external_id]).to include("can't be blank")
    end

    it "enforces uniqueness of external_id" do
      subject.save!
      duplicate = subject.dup
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:external_id]).to include("has already been taken")
    end

    it "validates that end_date is after start_date" do
      event = Event.new(
        title: "Conference",
        external_id: "conf-1",
        start_date: 2.days.from_now,
        end_date: 1.day.from_now
      )
      expect(event).not_to be_valid
      expect(event.errors[:end_date]).to include("must be after the start date")
    end
  end

  describe "#score" do
    it "calculates score as upvotes minus downvotes" do
      event = described_class.new(upvotes_count: 5, downvotes_count: 2)
      expect(event.score).to eq(3)
    end
  end
end