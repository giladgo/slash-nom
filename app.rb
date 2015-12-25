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
    respond "You have declared interest in going to #{decl.restaurant.name}. You can declare for more restaurants by typing `/um go [restaurant]`."
  else
    respond "You have already declared interest in going to #{decl.restaurant.name}. You can declare for other restaurants by typing `/um go [other-restaurant]`."
  end
end

def list(rest, params)
  # return list of declarations for today
  lines = Declaration.in_team(params['team_id']).for_today.group_by(&:restaurant).map do |rest, decls|
    users = decls.map(&:user_name)
    "#{rest.name}: #{users.join(', ')}"
  end
  respond lines.join("\n")
end

def help
  respond help_text
end

def emoji(rest, emoji)
  rest = Restaurant.in_team(params['team_id']).by_input(rest).first
  rest.emoji = emoji
  res.save

  respond "#{rest.name} now has the emoji #{rest.emoji}"
end

def respond(text)
  {text: text}
end

def respond_in_channel(text)
  {response_type: 'in_channel', text: text}
end

def help_text
<<-HELP
HELP
end
