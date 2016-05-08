class Team < ActiveRecord::Base

	def self.create_or_update_from_oauth(resp)
		current_team = self.find_by(team_id: resp.team_id)
    if current_team.present?
      current_team.assign_attributes(team_name: resp.team_name,
                                     bot_user_id: resp.bot.bot_user_id,
                                     bot_access_token: resp.bot.bot_access_token)
      current_team.save!
    else
      self.create!(team_name: resp.team_name,
                   bot_user_id: resp.bot.bot_user_id,
                   bot_access_token: resp.bot.bot_access_token,
                   team_id: resp.team_id)
    end
	end
end
