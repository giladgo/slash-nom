class PinnedMessage < ActiveRecord::Base

  scope :for_today,  ->() { where(message_date: DateTime.now.at_beginning_of_day.utc..Time.now.utc) }
  scope :in_channel, ->(team, channel) { where(team_id: team, channel_id: channel) }

  def self.last_pinned
    self.order('message_id DESC').first
  end

  def pin!(sc)
    begin
      sc.pins_add(channel: channel_id, timestamp: message_id)
    rescue Slack::Web::Api::Error =>
      raise e unless e.message == 'already_pinned'
    end
  end

  def unpin!(sc)
    begin
      sc.pins_remove(channel: channel_id, timestamp: message_id)
    rescue Slack::Web::Api::Error =>
      raise e unless e.message == 'not_pinned'
    end
  end

  def self.todays(team_id, channel_id)
    self.in_channel(team_id, channel_id).for_today.first
  end

end
