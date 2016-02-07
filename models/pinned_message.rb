class PinnedMessage < ActiveRecord::Base

  scope :for_today, ->() { where(message_date: DateTime.now.at_beginning_of_day.utc..Time.now.utc) }

end
