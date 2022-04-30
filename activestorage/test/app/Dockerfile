FROM ruby:2.7.5

RUN apt-get update -qq && apt-get -y install libxml2-dev libxslt-dev postgresql-client imagemagick

# RUN apk add --no-cache libxml2 libxslt && \
#         apk add --no-cache --virtual .gem-installdeps build-base libxml2-dev libxslt-dev && \
#         gem install nokogiri --platform=ruby -- --use-system-libraries && \
#         rm -rf $GEM_HOME/cache && \
#         apk del .gem-installdeps

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
# RUN gem install nokogiri
# RUN bundle config build.nokogiri --use-system-libraries
RUN gem install nokogiri --platform=ruby
# RUN gem install nokogiri --platform=ruby -- --use-system-libraries
RUN bundle install -j4
COPY . ./

EXPOSE 3000

CMD bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0
