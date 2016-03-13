class PinnedMessage < ActiveRecord::Base

  scope :for_today, ->() { where(message_date: DateTime.now.at_beginning_of_day.utc..Time.now.utc) }

  def self.last_pinned
    self.order('message_id DESC').first
  end

  def pin!(sc)
    sc.pins_add(channel: channel_id, timestamp: message_id)
  end

  def unpin!(sc)
    sc.pins_remove(channel: channel_id, timestamp: message_id) if slack_pinned?(sc)
  end

  def slack_pinned?(sc)
    sc.pins_list(channel: channel_id)["items"].any? do |pin|
      pin["message"]["ts"] == message_id
    end
  end

end
