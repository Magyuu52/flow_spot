FROM ruby:3.0.4
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y postgresql-client --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR /flow_spot

ADD Gemfile /flow_spot/Gemfile
ADD Gemfile.lock /flow_spot/Gemfile.lock

RUN gem install bundler
RUN bundle install

ADD . /flow_spot