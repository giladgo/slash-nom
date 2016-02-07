class CreatePinnedMessages < ActiveRecord::Migration
  def change
    create_table :pinned_messages do |t|
      t.string :message_id
      t.date :message_date
    end
  end
end
