require 'slack-ruby-client'
require 'sinatra/activerecord'

require './models/restaurant'
require './models/declaration'
require './models/pinned_message'
require './models/team'

require './commands/commands.rb'


class SlashNomServer

  def initialize
    @slack_client = Slack::Web::Client.new
  end

  def bot_user_id
    @user_info['user_id']
  end

  def in_channel?(channel_id, token)
    @slack_client.token = token
    if channel_id.start_with?("G")
      groups = @slack_client.groups_list(exclude_archived: 1)['groups']
      groups.any? { |group| group['id'] == channel_id }
    elsif channel_id.start_with?("C")
      channels = @slack_client.channels_list(exclude_archived: 1)['channels']
      channels.any? { |channel| channel['is_member'] == true && channel['id'] == channel_id }
    else
      false
    end
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

  def set_pinned_message(team_id, channel_id, token)
    pinned_msg = PinnedMessage.todays(team_id, channel_id)
    @slack_client.token = token
    if pinned_msg.present?
      @slack_client.chat_update(ts: pinned_msg.message_id, channel: channel_id, text: pinned_message_text(team_id, channel_id))
      false
    else
      response = @slack_client.chat_postMessage(channel: channel_id, text: pinned_message_text(team_id, channel_id), as_user: true)
      PinnedMessage.last_pinned.try(:unpin!, @slack_client)
      PinnedMessage.create(message_date: Date.today, message_id: response["ts"], team_id: team_id, channel_id: channel_id).pin!(@slack_client, params['slack_bot_token'])
      true
    end
  end

  def respond(text)
    {text: text}
  end

  def respond_in_channel(text)
    {response_type: 'in_channel', text: text}
  end


  def oauth(params)
    resp = @slack_client.oauth_access(client_id: ENV['SLACK_CLIENT_ID'],
                                      client_secret: ENV['SLACK_CLIENT_SECRET'],
                                      code: params['code'],
                                      redirect_uri: params['redirect_uri'])

    Team.create_or_update_from_oauth(resp)

  end

end
