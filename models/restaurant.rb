class Restaurant < ActiveRecord::Base
  has_many :declarations

  scope :in_team, ->(team) { where(team_id: team) }

  def self.by_input(input)
    self.where('lower(name) = ? OR emoji = ?', input.downcase, input.downcase).first_or_create(name: input)
  end

  def init_declaration(user_id, user_name, channel_id)
    declarations.for_today.create_with(user_name: user_name).find_or_initialize_by(
      user_id:    user_id,
      channel_id: channel_id,
      team_id:    self.team_id
    )
  end

  def display_name
    self.emoji.present? ? "#{self.emoji} #{self.name.titleize}" : self.name.titleize
  end

end
