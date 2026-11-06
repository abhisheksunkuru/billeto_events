class Event < ApplicationRecord
  validates :external_id, presence: true, uniqueness: true
  validates :title, presence: true
  validate :end_date_after_start_date

  scope :upcoming, -> { where("start_date >= ?", Time.current).order(start_date: :asc) }

  def score
    upvotes_count - downvotes_count
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
