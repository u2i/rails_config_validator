module RailsConfigValidator
  class Railtie < Rails::Railtie
    config.before_configuration do
      config.config_validator = ActiveSupport::OrderedOptions.new
      config.config_validator.files %w(database.yml)
    end

    initializer 'config_validator.configure' do
      config_paths = config.config_validator.files.map { |c| File.join(Rails.root, 'config', c) }

      validators = config_paths.map do |config|
        RailsConfigValidator::Validator.new(config, Rails.env)
      end

      validators.each(&:valid!)
    end
  end
end
