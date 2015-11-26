module RailsConfigValidator
  class Railtie < Rails::Railtie
    config.before_configuration do
      config.config_validator = ActiveSupport::OrderedOptions.new
      config.config_validator.configs %w(database)
    end

    initializer 'config_validator.configure' do
      validators = config.config_validator.configs.map do |config|
        RailsConfigValidator::Validator.new(config, Rails.env, pwd: Rails.root)
      end

      validators.each(&:valid!)
    end
  end
end
