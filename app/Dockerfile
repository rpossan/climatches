FROM ruby:latest

MAINTAINER ronaldo.possan@gmail.com

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y build-essential chrpath libssl-dev libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev && \
WORKDIR /opt
RUN git clone https://github.com/rpossan/climatches
WORKDIR /opt/climatches
RUN gem install bundler && \
  bundle install && \
  bundle exec rake env:init && \
  bundle exec rake db:setup && \
  bundle exec rake db:migrate
RUN bundle exec bin/rails runner -e test 'WeatherForecastJob.perform_now'
RUN bundle exec bin/rails runner -e test 'PlaylistsJob.perform_now'
RUN whenever
RUN rails server -e production -b 0.0.0.0