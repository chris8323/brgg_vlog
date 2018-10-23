class CreateDevicesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |d|
      d.integer :user_id
      d.string :os_ver
      d.string :push_token
      d.string :app_ver
    end
  end
end
