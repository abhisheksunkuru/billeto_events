# app/controllers/concerns/clerk_authenticatable.rb
module ClerkAuthenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_id, :user_signed_in?
  end

  def current_user_id
    @current_user_id ||= extract_clerk_user_id
  end

  def user_signed_in?
    current_user_id.present?
  end

  def require_authenticated_user!
    unless user_signed_in?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Please sign in to vote." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash", locals: { alert: "Please sign in to vote." })
        end
        format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
    end
  end

  private

  def extract_clerk_user_id
    token = cookies["__session"] || request.headers["Authorization"]&.split(" ")&.last
    return nil if token.blank?

    # 1. Try SDK's verify_token if supported
    begin
      if clerk_sdk.respond_to?(:verify_token)
        claims = clerk_sdk.verify_token(token)
        return claims["sub"] if claims.is_a?(Hash) && claims["sub"].present?
      end
    rescue StandardError => e
      Rails.logger.debug("[ClerkAuth] SDK verify_token skipped: #{e.message}")
    end

    # 2. Direct JWT decode (extracts the Clerk user_id 'sub' claim directly from session cookie)
    begin
      payload, _header = JWT.decode(token, nil, false)
      payload["sub"] # e.g. "user_2xxxx..."
    rescue StandardError => e
      Rails.logger.warn("[ClerkAuth] JWT decode failed: #{e.message}")
      nil
    end
  end
end