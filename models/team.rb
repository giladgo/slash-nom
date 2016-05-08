class Team < ActiveRecord::Base

	def self.create_or_update_from_oauth(resp)
		current_team = self.find_by(team_id: resp['team_id'])
    if current_team.present?
      current_team.assign_attributes(name: resp['team_name'],
                                     bot_user_id: resp['bot']['bot_user_id'],
                                     bot_access_token: resp['bot']['bot_access_token'])
      current_team.save!
    else
      self.create!(name: resp['team_name'],
                   bot_user_id: resp['bot']['bot_user_id'],
                   bot_access_token: resp['bot']['bot_access_token'],
                   team_id: resp['team_id'])
    end
	end

	def self.get_slack_bot_token(team_id)
		self.find_by(team_id: team_id).try(:bot_access_token)
	end
end
