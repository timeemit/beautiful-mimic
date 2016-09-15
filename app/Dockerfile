FROM ruby:2.3
EXPOSE 4567
COPY . .
RUN bundle install
CMD unicorn -p 4567
