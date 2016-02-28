class SlashUmServer

  def help
    respond help_text
  end

	def help_text
	<<-HELP
	`/um` is a slash command to help people decide where to go to lunch.
		Here are the available commands:
		`/um go [place]`
			Declare an interest in going to a place to eat.
			example: /um Rustico
		`/um ungo [place]`
			Regret the interest in going to a place.
			example /um ungo Rustico
		`/um list`
			Show where people want to go.
			example: /um list
		`/um emoji [emoji] [place]`
			Associate a place with an emoji.
			example: /um emoji :hamburger: McDonalds
		`/um help`
			Show this help message.
			example: /um help
	Enjoy!
	HELP
	end
end
