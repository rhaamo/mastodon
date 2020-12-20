Raven.configure do |config|
	config.dsn = ENV.fetch('RAVEN_DSN_RAILS')
end

Raven.configure do |config|
	config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
