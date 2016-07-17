require 'sinatra'
require 'sinatra/content_for'
require './server'
require 'awesome_print'

set :bind, '127.0.0.1'
set :server, "thin"

# prevent conneciton leaks
after do
  ActiveRecord::Base.connection.close
end
server = SlashNomServer.new

before do
  if params['team_id'].present?
    params['slack_bot_token'] = Team.get_slack_bot_token(params['team_id'])
  end
end

post '/nom' do
  content_type :json
  if params['text'].present?
    args = params['text'].split(' ', 2)
    response = case args.first
    when 'go', 'g' then server.go(args[1], params)
    when 'ungo', 'ug' then server.ungo(args[1], params)
    when 'list', 'l' then server.list(args[1], params)
    when 'emoji', 'e' then server.emoji(args[1], params)
    else server.help
    end
    response.to_json
  else
    ''
  end
end

get '/oauth' do
  server.oauth(params)
  redirect to('/thanks')
end

get '/' do
  haml :landing
end

get '/privacy' do
	haml :privacy
end

get '/contact' do
	haml :contact
end

get '/thanks' do
	haml :thanks
end
