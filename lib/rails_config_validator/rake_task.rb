require 'rake'
require 'rake/tasklib'

module RailsConfigValidator
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)

    def initialize
      require 'rails_config_validator/validator'

      desc 'Validates Rails config file against YML schema'
      namespace :config_validator do
        task :validate, [:config, :schema, :env] do |_, args|
          config, schema, env = args[:config], args[:schema], args[:env] || Rails.env
          fail 'Missing parameter :config' if args[:config].nil?

          v = RailsConfigValidator::Validator.new(config, env, schema_path: schema)
          v.valid!
        end
      end
    end
  end
end
