FROM ruby:latest

MAINTAINER ronaldo.possan@gmail.com

RUN apt-get update && \
  apt-get install -y postgresql postgresql-contrib &&\
  apt-get upgrade -y && \
  apt-get install -y build-essential chrpath libssl-dev libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev
RUN apt-get install sudo
# RUN service postgresql start && sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '123456'"
WORKDIR /opt
RUN git clone https://github.com/rpossan/climatches
WORKDIR /opt/climatches
RUN gem install bundler && \
  export SPOTIFY_CLIENT_ID=08d69f4b7c464d63bd0b67256aee3b8a && \
  export SPOTIFY_CLIENT_SECRET=0e988f1eb92b4b238c5104729124a640 && \
  service postgresql start && \
  sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '123456'" && \
  bundle install && \
  bundle exec rake env:init && \
  bundle exec rake db:create RAILS_ENV=development && \
  bundle exec rake db:migrate RAILS_ENV=development && \
  bundle exec rails runner -e development "PlaylistsJob.perform_now" && \
  # whenever && \
  rails server -e development -b 0.0.0.0