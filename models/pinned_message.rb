class PinnedMessage < ActiveRecord::Base

  scope :for_today,  ->() { where(message_date: DateTime.now.at_beginning_of_day.utc..Time.now.utc) }
  scope :in_channel, ->(team, channel) { where(team_id: team, channel_id: channel) }

  def self.last_pinned
    self.order('message_id DESC').first
  end

  def pin!(sc, token)
    sc.pins_add(channel: channel_id, timestamp: message_id)
  end

  def unpin!(sc, token)
    sc.pins_remove(channel: channel_id, timestamp: message_id) if slack_pinned?(sc)
  end

  def slack_pinned?(sc, token)
    sc.pins_list(token: token, channel: channel_id)["items"].any? do |pin|
      pin["message"]["ts"] == message_id
    end
  end

  def self.todays(team_id, channel_id)
    self.in_channel(team_id, channel_id).for_today.first
  end

end
