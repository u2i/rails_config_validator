require 'kwalify'
require 'yaml'
require 'rails_config_validator/errors'

module RailsConfigValidator
  class Validator
    def initialize(config_path, env, schema_path: nil)
      @config_path = config_path
      @schema_path = schema_path || config_to_schema_path(config_path)
      @env = env
    end

    def valid?
      meta_validate.empty? && validate.empty?
    rescue
      # ignored
      false
    end

    def valid!
      mv = meta_validate
      fail RailsConfigValidator::InvalidSchemaError,
           "Incorrect schema #{schema_path}; errors: #{mv}" unless mv.empty?
      v = validate
      fail RailsConfigValidator::InvalidConfigurationError,
           "Incorrect config #{config_path}; errors: #{v}" unless v.empty?
    end

    def meta_validate
      meta_validator = Kwalify::MetaValidator.instance
      errors = meta_validator.validate(schema)
      errors.map do |error|
        "[#{error.path}](#{error.error_symbol}) #{error.message}"
      end
    rescue Errno::ENOENT => e
      raise RailsConfigValidator::InvalidSchemaError, e
    end

    def validate
      validator = kwalify_validator
      env_settings = env_config
      errors = validator.validate(env_settings)
      errors.map do |error|
        "[#{error.path}](#{error.error_symbol}) #{error.message}"
      end
    rescue RailsConfigValidator::MissingConfigurationError => e
      [e.message]
    rescue Errno::ENOENT => e
      raise RailsConfigValidator::InvalidConfigurationError, e
    end

    private

    attr_reader :config_path, :schema_path

    def kwalify_validator
      Kwalify::Validator.new(schema)
    rescue Errno::ENOENT => e
      raise RailsConfigValidator::InvalidSchemaError, e
    end

    def schema
      ::YAML.load_file(schema_path)
    end

    def config
      ::YAML.load_file(config_path)
    end

    def env_config
      document = config
      fail RailsConfigValidator::MissingConfigurationError,
           "config file #{config_path} is empty" unless document
      fail RailsConfigValidator::MissingConfigurationError,
           "missing configuration for env #{@env} in #{config_path}" unless document.key?(@env)
      document[@env]
    end

    def config_to_schema_path(yml)
      yml.sub(/\.yml$/, '.schema.yml')
    end
  end
end
