# this is https://favorsrubytest2.herokuapp.com/

require 'sinatra'
require 'rest-client'
require 'sequel'
require 'pg'
require 'json/ext'

# check the ssh connection

# to run on mac:  ruby app.rb -s Puma
# to run locally on heroku: 
# heroku run bash -a favorsrubytest2
# ~ $ bundle exec ruby firebasepushserver.rb -s puma

# if app.rb doesn't run: 
# In my case I start to see this errors after installing rvm
# I resolve such problem with: gem pristine --all

# http://stackoverflow.com/questions/3183786/how-to-convert-a-ruby-hash-object-to-json
# require 'json/ext' # to use the C based extension instead of json/pure

# ruby version error: http://stackoverflow.com/questions/17415424/why-is-rails-using-the-wrong-version-of-ruby
# if rails sees wrong version of ruby, use command:  rvm --default use 2.3.3

# write script to commit to git and run git push heroku master

AUTHORIZE_KEY = "YOUR-FIREBASE-SERVER-KEY"

get '/' do
  "Hello World!"
end

# Create a SQLite3 database
# DB = Sequel.connect('sqlite://gcm-test.db')

# http://stackoverflow.com/questions/13319877/ruby-best-approach-to-create-a-postgresql-db
# DB = PG.connect(dbname: 'ruby-getting-started_production')   # paul -- need to create PG database for heroku
# DB = PG.connect(dbname: 'pg-dummy')   # paul -- need to create PG database for heroku
# DB = PG.connect(ENV['DATABASE_URL'])
DB = Sequel.connect(ENV['DATABASE_URL'])

# postgres table
#DB.exec "DROP TABLE IF EXISTS Device"
#DB.exec "CREATE TABLE Device(reg_id INTEGER PRIMARY KEY, user_id text, reg_token text, os text DEFAULT 'android')"

# Create a Device table if it doesn't exist
# old sqlite code
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