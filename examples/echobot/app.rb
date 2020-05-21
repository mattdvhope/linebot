require 'sinatra'   # gem 'sinatra'
require 'line/bot'  # gem 'line-bot-api'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = "04ad4901f521f3f8c041b3240765c409" # ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = "/pLbQN3KXuTyg9N1fr2uzheTnP9OiVBWLd6GlBgH4V//zHmtAFSK0Y293Fb9wKO4W1oI0b4ueFeYV64wGSvo3oC0Zxrs2B1ZuuAyqEZ7Go2u2zyLkfcT2SP5dpA4Y9nllkyxwDGjq13dptsAXLQ/CQdB04t89/1O/w1cDnyilFU=" # ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']

  CHANNEL_SECRET = "04ad4901f521f3f8c041b3240765c409"    # ENV["LINE_CHANNEL_SECRET"] # Channel secret string
  http_request_body = request.raw_post # Request body string
  hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
  signature_checked = Base64.strict_encode64(hash)

  # signature_verified = signature==signature_checked

  p "signature: " + signature
  p "signature_checked: " + signature_checked

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
