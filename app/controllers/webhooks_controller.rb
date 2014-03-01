class WebhooksController < ApplicationController
    # GET /webhooks
    # GET /webhooks.json
    def index
        @webhooks = Webhook.all

        render json: @webhooks
    end

    # GET /webhooks/1
    # GET /webhooks/1.json
    def show
        @webhook = Webhook.find(params[:id])

        render json: @webhook
    end

    # POST /webhooks
    # POST /webhooks.json
    def create
        Slack::Post.configure(
            subdomain: 'dramafever',
            token: '4Hz7p9h9mOAbuKMRk1gOH8Qg',
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

        if ['wea', 'weather'].include? first_word
            weather_json = JSON.parse(RestClient.get('https://api.forecast.io/forecast/2c66d239a4fa4a935a08cec02401ac9d/40.7436644,-73.985778'))
            currently = weather_json['currently']
            reply = "It is #{currently['summary']} and the temperature is #{currently['temperature']}F"
        end

        if ['bathroom', 'b'].include? first_word
            occupied = JSON.parse(RestClient.get('http://dfoccupied.appspot.com/latest.json'))['occupied']
            if occupied
                reply = "The bathroom is occupied. HOLD IT IN!"
            else
                reply = "The bathroom is free! RUN FOR IT!"
            end
        end

        if ['home'].include? first_word
            timenow = Time.now.in_time_zone("America/New_York")
            today_at_6 = Time.new(timenow.year, timenow.month, timenow.day, 18)
            if timenow < today_at_6
                time_until_6pm = view_context.distance_of_time_in_words(Time.new(timenow.year, timenow.month, timenow.day, 18) - Time.now)
                reply = "It is #{time_until_6pm} till 6pm!"
            else
                reply = "It's past 6! GO HOME!"
            end

        end

        Slack::Post.post reply.to_s, "##{params['channel_name']}"
    end

    # PATCH/PUT /webhooks/1
    # PATCH/PUT /webhooks/1.json
    def update
        @webhook = Webhook.find(params[:id])

        if @webhook.update_attributes(params[:webhook])
            head :no_content
        else
            render json: @webhook.errors, status: :unprocessable_entity
        end
    end

    # DELETE /webhooks/1
    # DELETE /webhooks/1.json
    def destroy
        @webhook = Webhook.find(params[:id])
        @webhook.destroy

        head :no_content
    end
end
