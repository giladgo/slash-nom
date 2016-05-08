class SlashNomServer

  def list(rest, params)
    lines = declaration_lines(params['team_id'], params['channel_id'])
    if lines.empty?
      respond "*Nobody wants to go anywhere today (#{DateTime.now.strftime("%A, %B %-d, %Y")}), be the first to show an interest in a place by entering `/nom go [place-name]`!*"
    else
      respond "*For #{DateTime.now.strftime("%A, %B %-d, %Y")}, people want to go to:*\n" + lines.join("\n")
    end
  end

end
