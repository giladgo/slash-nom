require 'sinatra'
require 'sinatra/activerecord'
require './models/restaurant'
require './models/declaration'
require 'awesome_print'
set :bind, '0.0.0.0'
set :server, "thin"

# prevent conneciton leaks
after do
  ActiveRecord::Base.connection.close
end

post '/um' do
  content_type :json
  if params['text'].present?
    args = params['text'].split(' ', 2)
    response = case args.first
    when 'go', 'g' then go(args[1], params)
    when 'list', 'l' then list(args[1], params)
    when 'emoji', 'e' then emoji(args[1], params)
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
    respond_in_channel "#{decl.user_name} wants to go to #{decl.restaurant.display_name}!"
  else
    respond "You have already shown interest in going to #{decl.restaurant.display_name} today. You can show interest in a differnt place by typing `/um go [other-place]`."
  end
end

def list(rest, params)
  # return list of declarations for today
  lines = Declaration.in_team(params['team_id']).for_today.group_by(&:restaurant).map do |rest, decls|
    users = decls.map(&:user_name)
    "#{rest.display_name}: #{users.join(', ')}"
  end
  if lines.empty?
    respond "*Nobody wants to go anywhere today (#{DateTime.now.strftime("%A, %B %-d, %Y")}), be the first to show an interest in a place by entering `/um go [place-name]`!*"
  else
    respond "*For #{DateTime.now.strftime("%A, %B %-d, %Y")}, people want to go to:*\n" + lines.join("\n")
  end
end

def help
  respond help_text
end

def emoji(args, params)
  ap args
  args = args.split(' ', 2)
  rest = Restaurant.in_team(params['team_id']).by_input(args[1])
  rest.emoji = args[0]
  rest.save!

  respond "#{rest.name.titleize}'s emoji is now #{rest.emoji}!"
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
  `/um go [place]`
    Declare an interest in going to a place to eat.
    example: /um Rustico
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
