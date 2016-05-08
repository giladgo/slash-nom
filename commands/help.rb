class SlashNomServer < Sinatra::Base

  def help
    respond help_text
  end

	def help_text
	<<-HELP
	`/nom` is a slash command to help people decide where to go to lunch.
		Here are the available commands:
		`/nom go [place]`
			Declare an interest in going to a place to eat.
			example: /nom Rustico
		`/nom ungo [place]`
			Regret the interest in going to a place.
			example /nom ungo Rustico
		`/nom list`
			Show where people want to go.
			example: /nom list
		`/nom emoji [emoji] [place]`
			Associate a place with an emoji.
			example: /nom emoji :hamburger: McDonalds
		`/nom help`
			Show this help message.
			example: /nom help
	Enjoy!
	HELP
	end
end
