class CreateDevicesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |d|
      d.integer :user_id
      d.string  :token
    end
  end
end
