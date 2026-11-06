# lib/tasks/billetto.rake
namespace :billetto do
  desc "Fetch and ingest public events from Billetto API"
  task sync_events: :environment do
    puts "Starting Billetto events sync..."
    synced_count = Billetto::SyncEventsService.new.call
    puts "Successfully synced #{synced_count} events from Billetto."
  rescue Billetto::ApiError => e
    warn "API Error during sync: #{e.message}"
    exit 1
  rescue StandardError => e
    warn "Unexpected error: #{e.message}"
    exit 1
  end
end