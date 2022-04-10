require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mofdb2
  class Application < Rails::Application

    config.load_defaults 7.0

    config.hosts << "local.northwestern.edu"
    config.hosts << "mof.tech.northwestern.edu"

    legacy_connection_handling = false
  end
end
