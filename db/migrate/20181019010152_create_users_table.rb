class CreateUsersTable < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |u|
      u.string :email
      u.string :sns_type
      u.string :sns_token
      u.datetime :joined_time     
    end 
  end
end
