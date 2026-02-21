# frozen_string_literal: true

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.

require_relative 'dotenv'

max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 15)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
#
worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
# In production, use Unix socket for better performance
#
if ENV.fetch('RAILS_ENV', 'development') == 'production'
  bind "unix:///var/www/gosign-app/shared/tmp/sockets/puma.sock"
else
  port ENV.fetch('PORT', 3000)
end

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch('RAILS_ENV', 'development')

# Specifies the `pidfile` that Puma will use.
@options[:pidfile] = false

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).

if ENV['WEB_CONCURRENCY_AUTO'] == 'true'
  require 'etc'

  workers Etc.nprocessors
else
  workers ENV.fetch('WEB_CONCURRENCY', 0)
end

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
# Enable preload_app in production for better memory usage and zero-downtime deploys
preload_app! if ENV.fetch('RAILS_ENV', 'development') == 'production'

# Hooks for zero-downtime deployment
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

# Sidekiq runs as separate worker process (see Procfile.dev / Procfile)
# Redis server plugin for non-multitenant setups
if (ENV['MULTITENANT'] != 'true' || ENV['DEMO'] == 'true') && ENV.fetch('RAILS_ENV', 'development') != 'development'
  require_relative '../lib/puma/plugin/redis_server'

  plugin :redis_server
end
