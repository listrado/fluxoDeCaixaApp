class AddUserClassToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :user_class, :string
  end
end
