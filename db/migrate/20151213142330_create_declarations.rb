class CreateDeclarations < ActiveRecord::Migration
  def up
    create_table :declarations do |t|
      t.string :team_id

      t.integer :restaurant_id
      t.string :user_id
      t.string :user_name
      t.string :channel_id

      t.timestamps null: false
    end
  end

  def down
    drop_table :declarations
  end
end
