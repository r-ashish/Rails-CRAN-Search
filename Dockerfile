FROM ruby:2.5
ENV HOME=/app

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir $HOME
WORKDIR $HOME
COPY Gemfile $HOME/Gemfile
COPY Gemfile.lock $HOME/Gemfile.lock
RUN bundle install
COPY . $HOME

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server"]