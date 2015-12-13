require 'sinatra'
require 'sinatra/activerecord'
require './models/run'
require './models/order'
require './config/environments'

post '/um' do
  content_type :json

  args = params['text'].split
  response = case args.first
  else help
  end
  response.to_json
end

def help
  respond help_text
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
