class SetDefaultUserClassOnUsers < ActiveRecord::Migration[7.1]
  def up
    # preenche quem já existe e está nulo
    execute "UPDATE users SET user_class = 'villager' WHERE user_class IS NULL"

    # define default pra futuros registros
    change_column_default :users, :user_class, from: nil, to: 'villager'

    # trava pra não aceitar nulo (com valor de backfill)
    change_column_null :users, :user_class, false, 'villager'
  end

  def down
    change_column_null :users, :user_class, true
    change_column_default :users, :user_class, from: 'villager', to: nil
  end
end
