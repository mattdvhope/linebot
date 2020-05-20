require 'sinatra'   # gem 'sinatra'
require 'line/bot'  # gem 'line-bot-api'

# get '/' do
#   "Hello there"
# end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = "04ad4901f521f3f8c041b3240765c409" # ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = "d88a80f7-03a8-4c1c-8f82-441a9eab2ba4" # ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    halt 400, {'Content-Type' => 'text/plain'}, 'Bad Request'
  end

  events = client.parse_events_from(body)

  events.each do |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: event.message['text']
        }
        client.reply_message(event['replyToken'], message)
      end
    end
  end

  "OK"
end
