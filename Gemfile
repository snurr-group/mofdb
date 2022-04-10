source 'https://rubygems.org'
git_source(:github) {|repo| "https://github.com/#{repo}.git"}

gem 'activerecord-import', "~>1.0"
gem "passenger", "~>6.0", require: "phusion_passenger/rack_handler"
gem 'rubyzip', '~>2.3'
gem 'concurrent-ruby', '~>1.1'
gem 'rails', '~> 7.0.0'
gem 'mysql2', '~> 0.5.3'

gem 'sass-rails', "~>6.0"
gem 'terser', '~>1.1.8'
gem 'zip_tricks', "~>5.5"
gem 'jbuilder', "~>2.11"
gem 'bootsnap', '~>1.7', require: false
gem 'dotenv-rails', "2.7.6"
gem 'nouislider-rails', "~>8.2"

gem "sentry-ruby", "~>5.2.1"
gem "sentry-rails", "~>5.2.1"


gem "strscan", "3.0.0"

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'bullet'
  # gem 'meta_request'
  # gem 'rack-mini-profiler'
  # gem 'memory_profiler'
  # gem 'flamegraph'
  # gem 'stackprof'
  # gem 'web-console', '>= 3.3.0'
  # gem 'factory_bot_rails'
  # gem 'faker'
  gem 'listen'
  gem "puma"
  # gem 'ruby-prof'
  gem 'rspec-rails'
  gem 'webdrivers'
  gem 'capybara'
end
