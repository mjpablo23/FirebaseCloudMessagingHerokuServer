# this is https://favorsrubytest2.herokuapp.com/
# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
# require './firebasepushserver.rb'
run Rails.application
# run Sinatra::Application
