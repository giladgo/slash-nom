require 'slack-ruby-client'
require 'sinatra/activerecord'

require './models/restaurant'
require './models/declaration'
require './models/pinned_message'

# TODO:
# 1. Fix the emojis

class SlashUmServer

  Slack.configure do |config|
    config.token = ENV['SLACK_API_TOKEN']
  end

  def initialize
    @slack_client = Slack::Web::Client.new
    puts 'Authenticating with slack'
    @user_info = @slack_client.auth_test
  end

  def bot_user_id
    @user_info['user_id']
  end

  def todays_pinned_message(channel_id)
		# TODO this needs to be by channel_id
    PinnedMessage.for_today.first
  end

  def declaration_lines(team_id, channel_id)
		Restaurant.joins(:declarations).merge(Declaration.in_channel(team_id, channel_id)).merge(Declaration.for_today).group("restaurants.id").order("count(declarations.restaurant_id) desc").map do |rest|
      users = rest.declarations.for_today.in_channel(team_id, channel_id).map(&:user_name)
      "#{rest.display_name}: #{users.join(', ')}"
    end
  end

  def pinned_message_text(team_id, channel_id)
    declaration_lines(team_id, channel_id).join("\n")
  end

  def set_pinned_message(team_id, channel_id)
    pinned_msg = todays_pinned_message(channel_id)
    if pinned_msg.present?
      @slack_client.chat_update(ts: pinned_msg.message_id, channel: channel_id, text: pinned_message_text(team_id, channel_id))
    else
      response = @slack_client.chat_postMessage(channel: channel_id, text: pinned_message_text(team_id, channel_id), as_user: true)
      @slack_client.pins_add(channel: channel_id, timestamp: response["ts"])
      PinnedMessage.create(message_date: Date.today, message_id: response["ts"])
    end
  end

  def go(rest, params)
    # Add a declaration
    decl = Restaurant.in_team(params['team_id']).by_input(rest).init_declaration(params['user_id'],
                                                                                 params['user_name'],
                                                                                 params['channel_id'])
    if decl.new_record?
      decl.save!
      set_pinned_message(params['team_id'], params['channel_id'])
      respond "You want to go to #{decl.restaurant.display_name}!"
    else
      respond "You have already shown interest in going to #{decl.restaurant.display_name} today. You can show interest in a differnt place by typing `/um go [other-place]`."
    end
  end

  def list(rest, params)
    lines = declaration_lines(params['team_id'], params['channel_id'])
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

end
