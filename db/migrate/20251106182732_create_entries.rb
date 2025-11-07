class CreateEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :entries do |t|
      t.date :date
      t.string :category
      t.text :description
      t.integer :kind
      t.decimal :amount, precision: 12, scale: 2
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
