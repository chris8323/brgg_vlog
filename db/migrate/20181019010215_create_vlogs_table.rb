class CreateVlogsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :vlogs do |v|
      v.integer :user_id
      v.datetime :create_date
      v.datetime :log_date
      v.string :feeling
      v.string :tag
      v.string :video_link
      v.string :thumbnail_link
      v.integer :video_ptime
    end
  end
end
