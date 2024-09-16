# Use the specific amd64 architecture Ruby image
FROM amd64/ruby:3.0.2-slim-buster

# Install dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential \
  git \
  nodejs \
  postgresql-client \
  libxml2-dev \
  libxslt1-dev \
  imagemagick \
  curl \
  libpq-dev \
  bash \
  && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock and install the gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the entire application code to the container
COPY . .

# Make the entrypoint script executable and set the entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Expose port 3000 to the outside world
EXPOSE 3000

# Start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]