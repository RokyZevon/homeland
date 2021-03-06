# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load

module Homeland
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.time_zone = ENV["timezone"] || "Beijing"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join("my", "locales", "*.{rb,yml}").to_s]
    config.i18n.default_locale = "zh-CN"
    config.i18n.available_locales = ["zh-CN", "en", "zh-TW"]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.i18n.fallbacks = true

    config.autoload_paths += [
      Rails.root.join("lib")
    ]

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    config.to_prepare do
      Devise::Mailer.layout "mailer"
      Doorkeeper::ApplicationController.include Homeland::UserNotificationHelper
      # Only Applications list
      Doorkeeper::ApplicationsController.layout "simple"
      # Only Authorization endpoint
      Doorkeeper::AuthorizationsController.layout "simple"
      # Only Authorized Applications
      Doorkeeper::AuthorizedApplicationsController.layout "simple"
    end

    config.action_cable.log_tags = [
      :action_cable, ->(request) { request.uuid }
    ]

    redis_config = Application.config_for(:redis)
    config.cache_store = [:redis_cache_store, { namespace: "cache", url: redis_config["url"], expires_in: 2.weeks }]

    config.active_job.queue_adapter = :sidekiq
    config.middleware.use Rack::Attack
    config.action_cable.mount_path = "/cable"
  end
end

require "homeland"
