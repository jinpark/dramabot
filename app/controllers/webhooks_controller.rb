class WebhooksController < ApplicationController

    # POST /webhooks
    # POST /webhooks.json
    def create
        Slack::Post.configure(
            subdomain: 'dramafever',
            token: ENV['SLACK_TOKEN'],
            username: 'dramabot',
            icon_emoji: ':ghost:'
        )
        # @webhook = Webhook.new(params[:webhook])

        # if @webhook.save
        #     render json: @webhook, status: :created, location: @webhook
        # else
        #     render json: @webhook.errors, status: :unprocessable_entity
        # end
        message = params['text']
        first_word = params['text'].split[1]

        if /\bweather\b/.match(message)
            weather_json = JSON.parse(RestClient.get("https://api.forecast.io/forecast/#{ENV['FORECAST_API_KEY']}/40.7436644,-73.985778"))
            currently = weather_json['currently']
            reply = "It is #{currently['summary']} and the temperature is #{currently['temperature']}F"
        end

        if /\bbathroom\b/.match(message)
            occupied = JSON.parse(RestClient.get('http://dfoccupied.appspot.com/latest.json'))['occupied']
            if occupied
                reply = "The bathroom is occupied. HOLD IT IN!"
            else
                reply = "The bathroom is free! RUN FOR IT!"
            end
        end

        if /\bhome\b/.match(message)
            timenow = Time.now.in_time_zone("Eastern Time (US & Canada)")
            today_at_6 = Time.new(timenow.year, timenow.month, timenow.day, 18, 0, 0, "-05:00")
            if timenow < today_at_6
                time_until_6pm = view_context.distance_of_time_in_words(today_at_6 - timenow)
                reply = "Get back to work! It is #{time_until_6pm} till 6pm!"
            else
                reply = "It's past 6! GO HOME!"
            end

        end

        if /\blunch\b/.match(message)

            doc = Nokogiri::HTML(open('https://zerocater.com/m/IMRP'))
            meal_item = doc.css('div.meal-item').last
            resto = meal_item.css('div.vendor').text.strip
            time = meal_item.css('div.header-time').text.strip.delete("\n")
            description = meal_item.css('div.vendor-description').text.strip
            meal_detail_title = meal_item.css('div.detail-view-header > div.order-name').text.strip
            detail_list = [] 
            meal_item.css('ul.item-list > li span').each do |span|
                detail_list << span.text.strip
            end

            reply = "Restaurant: #{resto}
                     Time: #{time}
                     Description: #{description}
                     Details: #{meal_detail_title}
                     More Details: #{detail_list.join(', ')}
                     More info at: https://zerocater.com/m/IMRP"

        end

        if /\blove\b/.match(message)
            username = params['user_name']
            reply = "#{username}: I :heart: you too!"
        end

        if first_word == '8ball'
            magic_answers = ["Duh",
                            "Hazy, try again",
                            "No way",
                            "Awoooga",
                            "We'll see",
                            "Of course!",
                            "Yawn...",
                            "Yep.",
                            "As If", 
                            "Ask Me If I Care",
                            "Dumb Question Ask Another", 
                            "Forget About It"," Get A Clue", "In Your Dreams", "No, Not A Chance", 
                            "Obviously", "Oh Please", "That's Ridiculous", "Well Maybe", "What Do You Think?", 
                            "Whatever", "Who Cares?", "Yeah And I'm The Pope", "Yah Right",  
                            "You Wish", "You've Got To Be Kidding...", "Go f*ck yourself"];

            reply = magic_answers.sample
        end 

        if reply
            Slack::Post.post reply.to_s, "##{params['channel_name']}"
        end

    end

end
