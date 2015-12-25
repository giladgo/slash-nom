class CreateRestaurants < ActiveRecord::Migration
  def up
    create_table :restaurants do |t|
      t.string :name
      t.string :emoji
      t.string :team_id

      t.timestamps null: false
    end
  end

  def down
    drop_table :restaurants
  end
end
