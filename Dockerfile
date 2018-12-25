FROM ruby:2.2.1
MAINTAINER Shane Burkhart <shaneburkhart@gmail.com>

RUN apt-get update

RUN mkdir -p /app
WORKDIR /app

ADD Gemfile Gemfile
RUN bundle install

ADD . /app

EXPOSE 3000

CMD ["echo", "Specify a command"]
