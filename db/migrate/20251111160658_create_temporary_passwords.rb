class CreateTemporaryPasswords < ActiveRecord::Migration[7.1]
  def change
    create_table :temporary_passwords do |t|
      t.string :password, null: false
      t.boolean :used, default: false
      t.datetime :used_at
      t.string :email

      t.timestamps
    end

    # Evita erro caso o índice já não exista no rollback
    reversible do |dir|
      dir.up do
        add_index :temporary_passwords, :password, unique: true
      end

      dir.down do
        if index_exists?(:temporary_passwords, :password)
          remove_index :temporary_passwords, :password
        end
      end
    end
  end
end
