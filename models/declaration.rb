class Declaration < ActiveRecord::Base
  belongs_to :restaurant

  scope :in_team, ->(team) { where(team_id: team) }

  def self.for_today
    self.includes(:restaurant).where(created_at: DateTime.now.at_beginning_of_day.utc..Time.now.utc)
  end
end
