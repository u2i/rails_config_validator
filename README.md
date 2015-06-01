# RailsConfigValidator

[![Build Status](https://travis-ci.org/u2i/rails_config_validator.svg)](https://travis-ci.org/u2i/rails_config_validator)
[![Dependency Status](https://gemnasium.com/u2i/rails_config_validator.svg)](https://gemnasium.com/u2i/rails_config_validator)
[![Code Climate](https://codeclimate.com/github/u2i/rails_config_validator/badges/gpa.svg)](https://codeclimate.com/github/u2i/rails_config_validator)
[![Test Coverage](https://codeclimate.com/github/u2i/rails_config_validator/badges/coverage.svg)](https://codeclimate.com/github/u2i/rails_config_validator/coverage)
[![Gem Version](https://badge.fury.io/rb/rails_config_validator.svg)](http://badge.fury.io/rb/rails_config_validator)

The gem uses [Kwalify](http://www.kuwata-lab.com/kwalify/) schema validator to check Rails configuration files syntax.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'rails_config_validator', '~> 0.1'
```

And then execute:

    $ bundle

Add Rake tasks to `Rakefile`:

```ruby
require 'rails_config_validator/rake_task'
RailsConfigValidator::RakeTask.new
```

Run Rake task to copy default `database.yml` schema file and add `config/database.schema.yml` to your version control:

    rake config_validator:init
    git add config/database.schema.yml

Specify files for which the gem should run validation `config/application.rb` or in environment file:

```ruby
config.config_validator.files = %w(database.yml your-config.yml)
```

## Usage

After deployment the schema can be validated with Rake task:

    export RAILS_ENV=production
    bundle exec rake config_validator:validate[config/database.yml]

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `bin/console` for an interactive prompt that will allow you to experiment.

Use `bundle exec guard` to run `rspec` and `rubocop` on each code change.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

1. [Fork it](https://github.com/u2i/rails_config_validator/fork)
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create a new Pull Request to branch `develop`.
