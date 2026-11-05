class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :external_id, null: false, index: { unique: true }
      t.string :title, null: false
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.string :image_url
      t.string :url
      t.integer :upvotes_count, default: 0, null: false
      t.integer :downvotes_count, default: 0, null: false

      t.timestamps
    end
  end
end
