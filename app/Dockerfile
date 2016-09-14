FROM ruby:2.2
EXPOSE 4567
COPY . .
RUN bundle install
CMD unicorn -p 4567
