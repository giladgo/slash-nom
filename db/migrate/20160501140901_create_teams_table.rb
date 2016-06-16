class CreateTeamsTable < ActiveRecord::Migration
  def up
    create_table :teams do |t|
      t.string :name
      t.string :team_id
      t.string :bot_user_id
      t.string :bot_access_token

      t.timestamps null: false
    end
  end

  def down

  end
end
