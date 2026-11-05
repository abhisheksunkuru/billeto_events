FactoryBot.define do
  factory :event do
    external_id { "MyString" }
    title { "MyString" }
    description { "MyText" }
    start_date { "2026-11-03 16:21:32" }
    end_date { "2026-11-03 16:21:32" }
    image_url { "MyString" }
    url { "MyString" }
    upvotes_count { 1 }
    downvotes_count { 1 }
  end
end
