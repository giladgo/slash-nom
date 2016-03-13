class AddTeamChannelToPinnedMessage < ActiveRecord::Migration
  def up
    add_column :pinned_messages, :team_id, :string
    add_column :pinned_messages, :channel_id, :string
  end

  def down
    remove_column :pinned_messages, :team_id
    remove_column :pinned_messages, :channel_id
  end
end
