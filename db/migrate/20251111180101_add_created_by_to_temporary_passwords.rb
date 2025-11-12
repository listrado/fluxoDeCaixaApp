class AddCreatedByToTemporaryPasswords < ActiveRecord::Migration[8.0]
  def change
    add_column :temporary_passwords, :created_by, :integer
  end
end
