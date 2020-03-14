require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mofdb2
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0


    config.hosts << "local.northwestern.edu"
    config.hosts << "mof.tech.northwestern.edu"
    if Rails.env.production?
      Raven.configure do |config|
        config.dsn = 'https://25089bbc81df4bf1bb44fa71f8e29faa:4eaaa398ad8f4baa8145a7a50a68f76f@sentry.io/1828682'
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
