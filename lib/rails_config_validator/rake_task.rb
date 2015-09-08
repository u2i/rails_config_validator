require 'rake'
require 'rake/tasklib'

module RailsConfigValidator
  class RakeTask < ::Rake::TaskLib
    def initialize
      require 'rails_config_validator/validator'

      namespace :config_validator do
        task_init
        task_validate
        task_validate_all
      end
    end

    private

    def task_init
      desc "Copies database.schema.yml to Rails's config directory"
      task :init do
        rake_file_dir = File.expand_path(File.dirname(__FILE__))
        FileUtils.cp(
          File.join(rake_file_dir, 'templates', 'database.schema.yml'),
          File.join(Dir.pwd, 'config')
        )
      end
    end

    def task_validate
      desc 'Validates Rails config file against YML schema'
      task :validate, [:config, :schema, :env] do |_, args|
        config = args[:config]
        schema = args[:schema]
        env = args[:env] || Rails.env
        fail 'Missing parameter :config' if args[:config].nil?

        v = RailsConfigValidator::Validator.new(config, env, schema)
        v.valid!
      end
    end

    def task_validate_all
      namespace :validate do
        desc 'Validates all Rails config files against YML schema'
        task :all, [:env] do |_, args|
          Rails.application.config.config_validator.configs.each do |file_name|
            Rake::Task['config_validator:validate'].invoke("config/#{file_name}.yml", nil, args[:env])
          end
        end
      end
    end
  end
end
