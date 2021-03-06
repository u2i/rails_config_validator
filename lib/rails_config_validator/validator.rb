require 'kwalify'
require 'yaml'
require 'erb'
require 'rails_config_validator/errors'

module RailsConfigValidator
  class Validator
    def initialize(config_name, env, options = {})
      @pwd = options[:pwd] || '.'
      @config_path = options[:config_path] || build_config_path(config_name)
      @schema_path = options[:schema_path] || build_schema_path(config_name)
      @env = env
      @raise_errors = options.fetch(:raise_errors, true)
    end

    def valid?
      meta_validate.empty? && validate.empty?
    rescue
      # ignored
      false
    end

    def valid!
      mv = meta_validate
      return error(
        InvalidSchemaError,
        "Incorrect schema #{schema_path}; errors: #{mv}"
      ) unless mv.empty?
      v = validate
      error(
        InvalidConfigurationError,
        "Incorrect config #{config_path}; errors: #{v}"
      ) unless v.empty?
    rescue InvalidConfigurationError, InvalidSchemaError => e
      error(e.class, e)
    end

    def meta_validate
      meta_validator = Kwalify::MetaValidator.instance
      errors = meta_validator.validate(schema)
      errors.map do |error|
        "[#{error.path}](#{error.error_symbol}) #{error.message}"
      end
    rescue Errno::ENOENT => e
      raise InvalidSchemaError, e
    end

    def validate
      validator = kwalify_validator
      env_settings = env_config
      errors = validator.validate(env_settings)
      errors.map do |error|
        "[#{error.path}](#{error.error_symbol}) #{error.message}"
      end
    rescue InvalidConfigurationError => e
      [e.message]
    rescue Errno::ENOENT => e
      raise InvalidConfigurationError, e
    end

    private

    attr_reader :config_path, :schema_path

    def error(*args)
      raise(*args) if @raise_errors
      warn(args.join("\n")) # Ruby 1.9 accepts only single argument
    end

    def kwalify_validator
      Kwalify::Validator.new(schema)
    rescue Errno::ENOENT => e
      raise InvalidSchemaError, e
    end

    def schema
      YAML.load_file(schema_path)
    end

    def config
      YAML.load(ERB.new(File.read(config_path)).result)
    end

    def env_config
      document = config
      raise InvalidConfigurationError,
            "config file #{config_path} is empty" unless document
      raise InvalidConfigurationError,
            "missing configuration for env #{@env} in #{config_path}" unless document.key?(@env)
      document[@env]
    end

    def build_config_path(config_name)
      File.join(@pwd, 'config', "#{config_name}.yml")
    end

    def build_schema_path(config_name)
      File.join(@pwd, 'config', 'schemas', "#{config_name}.schema.yml")
    end
  end
end
