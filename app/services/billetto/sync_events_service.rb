# app/services/billetto/sync_events_service.rb
module Billetto
  class SyncEventsService
    def initialize(client: Client.new)
      @client = client
    end

    def call
      payload = @client.fetch_public_events
      events_data = payload.is_a?(Array) ? payload : (payload["data"] || payload["events"] || [])

      synced = 0
      events_data.each do |data|
        event = Event.find_or_initialize_by(external_id: data["id"].to_s)
        event.assign_attributes(
          title: data["title"] || data["name"],
          description: data["description"] || data["summary"],
          start_date: data["startdate"] || data["start_date"],
          end_date: data["enddate"] || data["end_date"],
          image_url: data.dig("image", "url") || data["image_url"],
          url: data["url"]
        )
        if event.save
          synced += 1
        else
          Rails.logger.warn("[SyncEvents] Validation error for event #{data['id']}: #{event.errors.full_messages}")
        end
      end
      synced
    end
  end
end