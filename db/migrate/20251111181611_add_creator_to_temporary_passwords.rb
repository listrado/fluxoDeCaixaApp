# db/migrate/20251111181611_add_creator_to_temporary_passwords.rb
class AddCreatorToTemporaryPasswords < ActiveRecord::Migration[8.0]
  def up
    # 1) Renomeia created_by -> creator_id se for o caso
    if column_exists?(:temporary_passwords, :created_by) && !column_exists?(:temporary_passwords, :creator_id)
      rename_column :temporary_passwords, :created_by, :creator_id
    end

    # 2) Se por algum motivo não existir a coluna creator_id, cria como referência
    unless column_exists?(:temporary_passwords, :creator_id)
      add_reference :temporary_passwords, :creator, null: true, foreign_key: { to_table: :users }
    end

    # 3) Índice em creator_id
    unless index_exists?(:temporary_passwords, :creator_id)
      add_index :temporary_passwords, :creator_id
    end

    # 4) FK para users (alguns bancos criam com add_reference; garantimos aqui)
    unless foreign_key_exists?(:temporary_passwords, :users, column: :creator_id)
      add_foreign_key :temporary_passwords, :users, column: :creator_id
    end
  end

  def down
    # Remove FK e índice se existirem
    remove_foreign_key :temporary_passwords, column: :creator_id if foreign_key_exists?(:temporary_passwords, :users, column: :creator_id)
    remove_index :temporary_passwords, :creator_id if index_exists?(:temporary_passwords, :creator_id)

    # Se a coluna tiver sido criada por essa migration, podemos voltar
    if column_exists?(:temporary_passwords, :creator_id) && !column_exists?(:temporary_passwords, :created_by)
      # volta para o estado anterior
      rename_column :temporary_passwords, :creator_id, :created_by
    end
  end
end
