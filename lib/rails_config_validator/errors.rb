module RailsConfigValidator
  class Error < RuntimeError; end

  class InvalidConfigurationError < Error; end

  class InvalidSchemaError < Error; end
end
