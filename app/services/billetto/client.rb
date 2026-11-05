# app/services/billetto/client.rb
module Billetto
  class Client
    DEFAULT_BASE_URL = "https://billetto.co.uk/api/v3/public/".freeze

    def initialize(
      base_url: ENV.fetch("BILLETTO_BASE_URL", DEFAULT_BASE_URL),
      api_key: ENV["BILLETTO_API_KEY"],
      api_secret: ENV["BILLETTO_API_SECRET"]
    )
      @base_url = base_url.end_with?("/") ? base_url : "#{base_url}/"
      @api_key = sanitize(api_key)
      @api_secret = sanitize(api_secret)
    end

    def fetch_public_events(page: 1, limit: 20)
      response = connection.get("events") do |req|
        p req.inspect
        req.params["page"] = page
        req.params["limit"] = limit
        req.params["apikey"] = sanitize(@api_key)
      end

      handle_response(response)
    rescue Faraday::Error => e
      Rails.logger.error("[Billetto::Client] Network error: #{e.message}")
      raise ApiError, "Failed to reach Billetto API: #{e.message}"
    end

    private

    def sanitize(value)
      value.to_s.strip.gsub(/\A["']|["']\z/, "").delete('\\').presence
    end

    def connection
      @connection ||= Faraday.new(url: @base_url) do |conn|
        conn.headers["Accept"] = "application/json"
        #conn.headers["X-Access-Key-Id"] = @api_key

        # Billetto v3 expects these key headers:
        if @api_key.present?
          #conn.headers["Access-Key-Id"] = @api_key
          #conn.headers["X-API-KEY-SECRET"] = @api_secret if @api_secret.present?
          conn.headers["Api-Keypair"] = "#{@api_key}:#{@api_secret}" if @api_secret.present?
        end

        conn.adapter Faraday.default_adapter
      end
    end

    def handle_response(response)
      content_type = response.headers["content-type"] || ""

      unless content_type.include?("application/json")
        raise ApiError, "Expected JSON response but received #{content_type}. Status: #{response.status}. URL: #{response.env.url}"
      end

      case response.status
      when 200..299
        JSON.parse(response.body)
      else
        raise ApiError, "Billetto API returned HTTP #{response.status}: #{response.body}"
      end
    end
  end

  class ApiError < StandardError; end
end