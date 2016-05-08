require 'sinatra'
require './server'
require 'awesome_print'

set :bind, '127.0.0.1'
set :server, "thin"

# prevent conneciton leaks
after do
  ActiveRecord::Base.connection.close
end
server = SlashNomServer.new

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


get '/oauth' do
  server.oauth(params)
end

end
