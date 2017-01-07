This is a Firebase Cloud Messaging server that is deployed to Heroku, which is used for device-to-device push notifications, on Android.

The main file is firebasepushserver.rb.  

It is based on a file from codepath guides for FCM:  https://guides.codepath.com/android/Google-Cloud-Messaging#step-3-setup-web-server

The above guide is a good way to get started and get a FCM server running locally on your machine.  After that, I had to figure it out on my own.  Getting it deployed to Heroku and working took me about 3 days.  

The main difference from the sample code in the guide is that this version uses Postgres for its database.  

Main changes I had to make after cloning the ruby-getting-started git repository from Heroku:

1)  Add firebasepushserver.rb (based on codepath guide) and point the procfile to it.  Replace YOUR-FIREBASE-SERVER-KEY with your server key.

2)  Define AUTHORIZE_KEY in firebasepushserver.rb, which is the server key in the Firebase account for the app.

3)  Change the Sequel connect call in firebasepushserver.rb to:  DB = Sequel.connect(ENV['DATABASE_URL'])

4)  Include references for Sinatra using this guide, in section Frameworks -> Sinatra:  https://devcenter.heroku.com/articles/rack

5)  Add "run Sinatra::Application" to config.ru

6)  In Gemfile.lock, change tilt version to 1.4.1, since Sinatra doesn't work with tilt versions above 2.0.0

7)  In Gemfile, set:
	ruby '2.3.3'
	gem 'tilt', '~> 1.4.1', group: :production	
	gem 'sinatra'
	gem 'rest-client'
	gem 'sequel'

8) At top of firebasepushserver.rb, set:
	require 'pg'
	require 'json/ext'

9) In config/puma.rb, comment out first line: # workers Integer(ENV['WEB_CONCURRENCY'] || 2)

10) In database.yml, make sure adapter is postgresql

11) Change the remote git url's:  https://help.github.com/articles/changing-a-remote-s-url/

12) HttpClientWrapperForFCM.java is the file for calling it from android

------------------------------------------------------------------------------------------------------------------
# ruby-getting-started

A barebones Rails app, which can easily be deployed to Heroku.

This application support the [Getting Started with Ruby on Heroku](https://devcenter.heroku.com/articles/getting-started-with-ruby) article - check it out.

## Running Locally

Make sure you have Ruby installed.  Also, install the [Heroku Toolbelt](https://toolbelt.heroku.com/).

```sh
$ git clone git@github.com:heroku/ruby-getting-started.git
$ cd ruby-getting-started
$ bundle install
$ bundle exec rake db:create db:migrate
$ heroku local
```

Your app should now be running on [localhost:5000](http://localhost:5000/).

## Deploying to Heroku

```sh
$ heroku create
$ git push heroku master
$ heroku run rake db:migrate
$ heroku open
```

or

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Docker

The app can be run and tested using the [Heroku Docker CLI plugin](https://devcenter.heroku.com/articles/introduction-local-development-with-docker).

Make sure the plugin is installed:

    heroku plugins:install heroku-docker

Configure Docker and Docker Compose:

    heroku docker:init

And run the app locally:

    docker-compose up web

The app will now be available on the Docker daemon IP on port 8080.

To work with the local database and do migrations, you can open a shell:

    docker-compose run shell
    bundle exec rake db:migrate

You can also use Docker to release to Heroku:

    heroku create
    heroku docker:release
    heroku open

## Documentation

For more information about using Ruby on Heroku, see these Dev Center articles:

- [Ruby on Heroku](https://devcenter.heroku.com/categories/ruby)

