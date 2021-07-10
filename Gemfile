source 'https://rubygems.org'
git_source(:github) {|repo| "https://github.com/#{repo}.git"}

gem 'activerecord-import'
gem "passenger", ">= 5.3.2", require: "phusion_passenger/rack_handler"
gem 'rubyzip'
gem 'concurrent-ruby'
gem 'rails', '~> 6.0'

gem 'mysql2', '>= 0.4.4', '< 0.6.0'

gem 'sass-rails'
gem 'uglifier'

gem 'zip_tricks'
gem 'jbuilder'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'dotenv-rails'
gem 'nouislider-rails'

gem "sentry-ruby"
gem "sentry-rails"

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'bullet'
  gem 'meta_request'
  # gem 'rack-mini-profiler'
  # gem 'memory_profiler'
  # gem 'flamegraph'
  # gem 'stackprof'
  gem 'web-console', '>= 3.3.0'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem "puma", "~> 5.3"
  # gem 'ruby-prof'
end
