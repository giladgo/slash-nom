class SlashUmServer

  def emoji(args, params)
    ap args
    args = args.split(' ', 2)
    rest = Restaurant.in_team(params['team_id']).by_input(args[1])
    rest.emoji = args[0]
    rest.save!

    respond "#{rest.name.titleize}'s emoji is now #{rest.emoji}!"
  end
	
end
