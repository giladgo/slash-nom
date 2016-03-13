class SlashUmServer

  def go(rest, params)
    # Add a declaration
    decl = Restaurant.in_team(params['team_id']).by_input(rest).init_declaration(params['user_id'],
                                                                                 params['user_name'],
                                                                                 params['channel_id'])
    if decl.new_record?
      decl.save!
      if set_pinned_message(params['team_id'], params['channel_id'])
        # new message
        respond_in_channel "@here, #{params['user_name']} wants to go to #{decl.restaurant.display_name}! Join them by typing `/um go <place>.`"
      else
        respond "You want to go to #{decl.restaurant.display_name}!"
      end
    else
      respond "You have already shown interest in going to #{decl.restaurant.display_name} today. You can show interest in a differnt place by typing `/um go [other-place]`."
    end
  end

end
