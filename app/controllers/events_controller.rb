# app/controllers/events_controller.rb
class EventsController < ApplicationController
  before_action :require_authenticated_user!, only: [:upvote, :downvote]
  before_action :set_event, only: [:upvote, :downvote]

  def index
    @events = Event.order(created_at: :desc)
  end

  def upvote
    VoteService.new.upvote(event_id: @event.id, user_id: current_user_id)
    redirect_back fallback_location: events_path, notice: "Upvoted!"
  end

  def downvote
    VoteService.new.downvote(event_id: @event.id, user_id: current_user_id)
    redirect_back fallback_location: events_path, notice: "Downvoted!"
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end
end