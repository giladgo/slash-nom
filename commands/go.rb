class SlashNomServer

  def go(rest, params)
    if not in_channel?(params['channel_id'], params['slack_bot_token'])
      respond "Please call me from a channel or group I've been invited to."
    else
      # Add a declaration
      decl = Restaurant.in_team(params['team_id']).by_input(rest).init_declaration(params['user_id'],
                                                                                   params['user_name'],
                                                                                   params['channel_id'])
      if decl.new_record?
        decl.save!
        if set_pinned_message(params['team_id'], params['channel_id'], params['slack_bot_token'])
          # new message
          respond_in_channel "#{params['user_name']} wants to go to #{decl.restaurant.display_name}! Join them by typing `/nom go <place>.`"
        else
          respond "You want to go to #{decl.restaurant.display_name}!"
        end
      else
        respond "You have already shown interest in going to #{decl.restaurant.display_name} today. You can show interest in a differnt place by typing `/nom go [other-place]`."
      end
    end
  end

end
