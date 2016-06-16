class SlashNomServer

  def emoji(args, params)
    ap args
    args = args.split(' ', 2)
    rest = Restaurant.in_team(params['team_id']).by_input(args[1])
    rest.emoji = args[0]
    rest.save!

    set_pinned_message(params['team_id'], params['channel_id'], params['slack_bot_token'])

    respond "#{rest.name.titleize}'s emoji is now #{rest.emoji}!"
  end

end
