FROM ruby:2.3.1

ENV TEST_HOME=/pipes
ADD *.gemspec $TEST_HOME/
ADD Gemfile $TEST_HOME/
WORKDIR $TEST_HOME

RUN bundle install --jobs 8 --retry 5

ADD . $TEST_HOME
