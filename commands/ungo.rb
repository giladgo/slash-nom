class SlashNomServer

  def ungo(rest, params)
    if not in_channel?(params['channel_id'], params['slack_bot_token'])
      respond "Please call me from a channel i've been invited to."
    else
      decl = Restaurant.in_team(params['team_id']).by_input(rest).declaration_for_user(params['user_id'], params['channel_id'])

      if decl.present?
        decl.destroy
        set_pinned_message(params['team_id'], params['channel_id'], params['slack_bot_token'])
        respond "You don't want to got to #{decl.restaurant.display_name}."
      else
        respond "You can ungo to a place you didn't delcare for"
      end
    end
  end

end
