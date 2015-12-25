require 'sinatra'
require 'sinatra/activerecord'
require './models/restaurant'
require './models/declaration'
require './config/environments'
require 'awesome_print'
set :port, 31385

post '/um' do
  ap params
  content_type :json
  if params['text'].present?
    args = params['text'].split
    response = case args.first
    when 'go', 'g' then go(args[1], params)
    when 'list', 'l' then list(args[1], params)
    when 'emoji', 'e' then emoji(args[1], args[2], params)
    else help
    end
    response.to_json
  else
    ''
  end

end

def go(rest, params)
  # Add a declaration
  decl = Restaurant.in_team(params['team_id']).by_input(rest).init_declaration(params['user_id'],
                                                                               params['user_name'],
                                                                               params['channel_id'])
  if decl.new_record?
    decl.save!
    respond_in_channel "#{decl.user_name} wants to go to #{decl.restaurant.display_name}! Join them by entering `/um go #{decl.restaurant.display_name}`, or show an interest in a different place by typing `/um go [other-place]`."
  else
    respond "You have already shown interest in going to #{decl.restaurant.display_name}. You can show interest in a differnt place by typing `/um go [other-place]`."
  end
end

def list(rest, params)
  # return list of declarations for today
  lines = Declaration.in_team(params['team_id']).for_today.group_by(&:restaurant).map do |rest, decls|
    users = decls.map(&:user_name)
    "#{rest.name}: #{users.join(', ')}"
  end
  respond "*For #{DateTime.now.strftime("%A, %B %-d, %Y")}, people want to go to:*\n" + lines.join("\n")
end

def help
  respond help_text
end

def emoji(rest, emoji, params)
  rest = Restaurant.in_team(params['team_id']).by_input(rest)
  rest.emoji = emoji
  rest.save!

  respond "#{rest.name}'s emoji is now #{rest.emoji}!"
end

def respond(text)
  {text: text}
end

def respond_in_channel(text)
  {response_type: 'in_channel', text: text}
end

def help_text
<<-HELP
`/um` is a slash command to help people decide where to go to lunch.
  Here are the available commands:
  `/um go [restaurant]`
    Declare an interest in going to a place to eat.
    example: /um Rustico
  `/um list`
    Show where people want to go.
    example: /um list
  `/um help`
    Show this help message.
    example: /um help
Enjoy!
HELP
end
