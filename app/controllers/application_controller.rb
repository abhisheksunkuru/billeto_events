class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  include ClerkAuthenticatable
  before_action :debug_clerk_auth

  def debug_clerk_auth
    Rails.logger.debug("[Clerk Debug] Cookies: #{cookies.to_h.keys.inspect}")
    Rails.logger.debug("[Clerk Debug] __session cookie present?: #{cookies['__session'].present?}")
    Rails.logger.debug("[Clerk Debug] current_user_id: #{current_user_id.inspect}")
  end
end
