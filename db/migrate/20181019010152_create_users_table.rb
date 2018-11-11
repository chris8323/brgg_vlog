class CreateUsersTable < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |u|
      u.string :email
      u.string :nickname
      u.string :password
    end 
  end
end
