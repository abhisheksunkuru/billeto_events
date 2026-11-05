class Event < ApplicationRecord
  validates :external_id, presence: true, uniqueness: true
  validates :title, presence: true

  scope :upcoming, -> { where("start_date >= ?", Time.current).order(start_date: :asc) }

  def score
    upvotes_count - downvotes_count
  end
end
