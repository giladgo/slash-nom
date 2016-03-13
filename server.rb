require 'slack-ruby-client'
require 'sinatra/activerecord'

require './models/restaurant'
require './models/declaration'
require './models/pinned_message'

require './commands/commands.rb'


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
      false
    else
      response = @slack_client.chat_postMessage(channel: channel_id, text: pinned_message_text(team_id, channel_id), as_user: true)
      PinnedMessage.last_pinned.unpin!(@slack_client)
      PinnedMessage.create(message_date: Date.today, message_id: response["ts"]).pin!(@slack_client)
      true
    end
  end

  def respond(text)
    {text: text}
  end

  def respond_in_channel(text)
    {response_type: 'in_channel', text: text}
  end


end
