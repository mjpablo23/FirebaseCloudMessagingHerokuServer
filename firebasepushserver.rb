# this is https://favorsrubytest2.herokuapp.com/

require 'sinatra'
require 'rest-client'
require 'sequel'
require 'json/ext'

# to run:  ruby app.rb -s Puma

# if app.rb doesn't run: 
# In my case I start to see this errors after installing rvm
# I resolve such problem with: gem pristine --all

# http://stackoverflow.com/questions/3183786/how-to-convert-a-ruby-hash-object-to-json
# require 'json/ext' # to use the C based extension instead of json/pure

# ruby version error: http://stackoverflow.com/questions/17415424/why-is-rails-using-the-wrong-version-of-ruby
# if rails sees wrong version of ruby, use command:  rvm --default use 2.3.3

AUTHORIZE_KEY = "AAAAGrYxdas:APA91bF3-b0qxflb9rkEkkTahh9oqS3F2lA2CUVlDRbcGYaQIjaSVAAy1wpSdZyxJCy7zlCRURBLf_LBdbjwrnqz7bOz12fy9lC7sXAhYSwHSWSwEiTpDhzx6UET2hYxL9kh3IYlVi6JULuNY_Xv2tucsf4CPAFUEQ"

# Create a SQLite3 database
DB = Sequel.connect('sqlite://gcm-test.db')

# Create a Device table if it doesn't exist
DB.create_table? :Device do
  primary_key :reg_id
  String :user_id
  String :reg_token
  String :os, :default => 'android'
end

Device = DB[:Device]  # create the dataset

# Registration endpoint mapping reg_token to user_id
# POST /register?reg_token=abc&user_id=123
post '/register' do
  if Device.filter(:reg_token => params[:reg_token]).count == 0
    device = Device.insert(:reg_token => params[:reg_token], :user_id => params[:user_id], :os => 'android')
  end
end

# Ennpoint for sending a message to a user
# POST /send?user_id=123&title=hello&body=message
post '/send' do
  # Find devices with the corresponding reg_tokens
  reg_tokens = Device.filter(:user_id => params[:user_id]).map(:reg_token).to_a
  if reg_tokens.count != 0
    send_gcm_message(params[:title], params[:body], reg_tokens)
  end
end

# Sending logic
# send_gcm_message(["abc", "cdf"])
def send_gcm_message(title, body, reg_tokens)
  # Construct JSON payload
  post_args = {
    # :to field can also be used if there is only 1 reg token to send
    :registration_ids => reg_tokens,
    # http://stackoverflow.com/questions/37584693/error-in-remotemessage-getnotification-getbody
    :notification => {
    	:body => body,
    	:title => title
    }
  }
# http://stackoverflow.com/questions/38154263/what-should-i-specify-for-authorization-key-in-firebase-cloud-messaging
# the "Authorization" should be the "Server Key" found on the Firebase console under my project's Cloud Messaging tab.
  # Send the request with JSON args and headers
  RestClient.post 'https://gcm-http.googleapis.com/gcm/send', post_args.to_json,
    :Authorization => 'key=' + AUTHORIZE_KEY, :content_type => :json, :accept => :json
end