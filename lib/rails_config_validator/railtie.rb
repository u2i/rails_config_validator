module RailsConfigValidator
  class Railtie < Rails::Railtie
    config.before_configuration do
      config.config_validator = ActiveSupport::OrderedOptions.new
      config.config_validator.configs %w(database)
      config.config_validator.raise_errors true
    end

    rake_tasks do
      require_relative 'rake_task'

      RailsConfigValidator::RakeTask.new
    end

    initializer 'config_validator.configure' do
      raise_errors = config.config_validator.raise_errors
      validators = config.config_validator.configs.map do |config|
        RailsConfigValidator::Validator.new(config, Rails.env, pwd: Rails.root, raise_errors: raise_errors)
      end

      validators.each(&:valid!)
    end
  end
end
