# config/initializers/clerk.rb
require "clerk"
Clerk.configure do |config|
  config.secret_key = ENV["CLERK_SECRET_KEY"]
end