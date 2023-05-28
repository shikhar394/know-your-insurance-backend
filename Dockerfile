# Use an official Ruby runtime as a parent image
FROM ruby:3.2.2

# Install system dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install yarn && apt-get install -y build-essential libpq-dev nodejs

# Set the working directory in the Docker image
WORKDIR /ask_book_rails

# Add the Gemfile and Gemfile.lock from your app
COPY Gemfile* ./

# Install any new gems
RUN bundle install

# Add the rest of your app's code
COPY . .

# Install JavaScript dependencies
RUN yarn install

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# The command to run the app using Puma (adjust as necessary)
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
