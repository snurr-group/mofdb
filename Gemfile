source 'https://rubygems.org'
git_source(:github) {|repo| "https://github.com/#{repo}.git"}

gem 'activerecord-import'
gem "passenger", ">= 5.3.2", require: "phusion_passenger/rack_handler"
gem 'rubyzip', '1.3.0'
gem 'rails', '~> 6.0'

gem 'rails-erd', group: :development
gem 'mysql2', '>= 0.4.4', '< 0.6.0'

gem 'rack-mini-profiler'
gem 'memory_profiler'
gem 'flamegraph'
gem 'stackprof'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

gem 'jbuilder', '~> 2.5'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'dotenv-rails'
gem 'nouislider-rails'

group :production do
  gem "sentry-raven"
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'bullet'
  gem 'web-console', '>= 3.3.0'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
end