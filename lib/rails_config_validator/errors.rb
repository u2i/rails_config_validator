module RailsConfigValidator
  class Error < RuntimeError; end

  class MissingConfigurationError < Error; end

  class InvalidConfigurationError < Error; end

  class InvalidSchemaError < Error; end
end
