persistent_timeout ENV.fetch('PERSISTENT_TIMEOUT') { 20 }.to_i

threads_count = ENV.fetch('MAX_THREADS') { 5 }.to_i
threads threads_count, threads_count

if ENV['SOCKET']
  bind "unix://#{ENV['SOCKET']}"
else
  bind "tcp://#{ENV.fetch('BIND', '127.0.0.1')}:#{ENV.fetch('PORT', 3000)}"
end

environment ENV.fetch('RAILS_ENV') { 'development' }
workers     ENV.fetch('WEB_CONCURRENCY') { 2 }

lowlevel_error_handler do |ex, env|
	Raven.capture_exception(
		ex,
		:message => ex.message,
		:extra => { :puma => env },
		:culprit => "Puma"
	)
	# note the below is just a Rack response
	[500, {}, ["An error has occurred, and engineers have been informed. Please reload the page. If you continue to have problems, contact dashie@sigpipe.me\n"]]
end

preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

plugin :tmp_restart
