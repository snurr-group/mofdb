unless Rails.env.development? || Rails.env.test?
  raise
  Sentry.init do |config|
    config.dsn = 'https://25089bbc81df4bf1bb44fa71f8e29faa@o310079.ingest.sentry.io/1828682'
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # To activate performance monitoring, set one of these options.
    # We recommend adjusting the value in production:
    config.traces_sample_rate = 0.05
  end
end