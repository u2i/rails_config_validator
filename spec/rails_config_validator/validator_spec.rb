require 'spec_helper'

RSpec.describe RailsConfigValidator::Validator do
  let(:dir) { Dir.mktmpdir }
  let(:schema_path) { File.join(dir, 'config/schemas', "#{config_name}.schema.yml") }
  let(:config_path) { File.join(dir, 'config', "#{config_name}.yml") }
  let(:config_name) { 'config' }
  let(:env) { 'test' }
  let(:schema) { margin_schema.gsub(/^\s*\|/, '') }
  let(:config) { margin_config.gsub(/^\s*\|/, '') }
  let(:raise_errors_option) { true }
  let(:opts) { {pwd: dir} }
  before { FileUtils.mkpath(File.join(dir, 'config/schemas')) }

  shared_examples_for 'valid configuration' do
    describe '#valid?' do
      subject { validator.valid? }

      it 'is invalid' do
        expect(subject).to eq(true)
      end
    end

    describe '#valid!' do
      subject { validator.valid! }

      let(:opts) { {pwd: dir, raise_errors: raise_errors_option} }

      context 'when raise_error is set to true' do
        let(:raise_errors_option) { true }

        it 'does not raise error' do
          expect { subject }.not_to raise_error
        end

        it 'does not display warning' do
          expect { subject }.not_to output.to_stderr
        end
      end

      context 'when raise_error is set to false' do
        let(:raise_errors_option) { false }

        it 'does not raise error' do
          expect { subject }.not_to raise_error
        end

        it 'does not display warning' do
          expect { subject }.not_to output.to_stderr
        end
      end
    end
  end

  shared_examples_for 'invalid configuration' do
    describe '#valid?' do
      subject { validator.valid? }

      it 'is invalid' do
        expect(subject).to eq(false)
      end
    end

    describe '#valid!' do
      subject { validator.valid! }

      let(:opts) { {pwd: dir, raise_errors: raise_errors_option} }
      let(:expected_warning) { /^RailsConfigValidator::InvalidConfigurationError\n#{warning_message}/ }
      let(:warning_message) { /^(Incorrect config .+; errors: |No such file or directory)/ }

      context 'when raise_error is set to true' do
        let(:raise_errors_option) { true }

        it 'raises error' do
          expect { subject }.to raise_error(RailsConfigValidator::InvalidConfigurationError, warning_message)
        end

        it 'does not display warning' do
          expect { subject rescue nil }.not_to output.to_stderr
        end
      end

      context 'when raise_error is set to false' do
        let(:raise_errors_option) { false }

        it 'displays warning' do
          expect { subject }.to output(expected_warning).to_stderr
        end
      end
    end
  end

  shared_examples_for 'invalid schema' do
    describe '#valid?' do
      subject { validator.valid? }

      it 'is invalid' do
        expect(subject).to eq(false)
      end
    end

    describe '#valid!' do
      subject { validator.valid! }

      let(:opts) { {pwd: dir, raise_errors: raise_errors_option} }
      let(:expected_warning) { /^RailsConfigValidator::InvalidSchemaError\n#{warning_message}/ }
      let(:warning_message) { /^(Incorrect schema .+; errors: |No such file or directory)/ }

      context 'when raise_error is set to true' do
        let(:raise_errors_option) { true }

        it 'raises error' do
          expect { subject }.to raise_error(RailsConfigValidator::InvalidSchemaError, warning_message)
        end

        it 'does not display warning' do
          expect { subject rescue nil }.not_to output.to_stderr
        end
      end

      context 'when raise_error is set to false' do
        let(:raise_errors_option) { false }

        it 'displays warning' do
          expect { subject }.to output(expected_warning).to_stderr
        end
      end
    end
  end

  describe '#meta_validate' do
    let(:validator) { described_class.new(config_name, env, opts) }

    subject { validator.meta_validate }

    context 'when schema file is missing' do
      it 'reports error' do
        expect { subject }.to raise_error(RailsConfigValidator::InvalidSchemaError)
      end

      it_behaves_like 'invalid schema'
    end

    context 'when schema file exists' do
      before { File.write(schema_path, schema) }

      context 'when schema file is empty' do
        let(:margin_schema) { '' }

        it 'returns errors' do
          expect(subject).not_to be_empty
        end

        it_behaves_like 'invalid schema'
      end

      context 'when schema file is valid' do
        let(:margin_schema) do
          <<-YML
          |type:   seq
          |sequence:
          |  - type:   str
          YML
        end

        it 'returns no errors' do
          expect(subject).to be_empty
        end
      end

      context 'when schema file is corrupted' do
        let(:margin_schema) do
          <<-YML
          |type:   seq
          YML
        end

        it 'returns errors' do
          expect(subject).not_to be_empty
        end

        it_behaves_like 'invalid schema'
      end

      context 'when schema file rubish' do
        let(:margin_schema) do
          <<-YML
          |<xml></xml>
          YML
        end

        it 'returns errors' do
          expect(subject).not_to be_empty
        end

        it_behaves_like 'invalid schema'
      end
    end
  end

  describe '#validate' do
    let(:validator) { described_class.new(config_name, env, opts) }

    subject { validator.validate }

    context 'when schema file is missing' do
      it 'reports error' do
        expect { subject }.to raise_error(RailsConfigValidator::InvalidSchemaError)
      end

      it_behaves_like 'invalid schema'
    end

    context 'when schema file exists' do
      let(:margin_schema) do
        <<-YML
        |type: map
        |mapping:
        |  adapter:
        |    type: str
        |    required: true
        |  pool:
        |    type: int
        |  timeout:
        |    type: int
        |  database:
        |    type: str
        |  hostname:
        |    type: str
        |  username:
        |    type: str
        |  password:
        |    type: str
        |  socket:
        |    type: str
        |  encoding:
        |    type: str
        |  port:
        |    type: int
        |    range:
        |      min: 0
        |      max: 65535
        YML
      end

      before { File.write(schema_path, schema) }

      context 'when config file is missing' do
        it 'reports error' do
          expect { subject }.to raise_error(RailsConfigValidator::InvalidConfigurationError)
        end

        it_behaves_like 'invalid configuration'
      end

      context 'when config file exists' do
        before { File.write(config_path, config) }

        context 'when config file is empty' do
          let(:margin_config) do
            <<-YAML
            YAML
          end

          it 'has no errors' do
            expect(subject).not_to be_empty
          end

          it 'reports empty config file' do
            expect(subject.first).to match(/config file .+ is empty$/)
          end

          it_behaves_like 'invalid configuration'
        end

        context 'when requested environment config is not present' do
          let(:margin_config) do
            <<-YAML
            |default: &default
            |  adapter: sqlite3
            |  pool: 5
            |  timeout: 5000
            |#{env + '2'}:
            |  <<: *default
            YAML
          end

          it 'has no errors' do
            expect(subject).not_to be_empty
          end

          it 'reports empty config file' do
            expect(subject.first).to match(/missing configuration for env #{env} in .+$/)
          end

          it_behaves_like 'invalid configuration'
        end

        context 'when requested environment is present' do
          let(:margin_config) do
            <<-YAML
            |default: &default
            |  adapter: sqlite3
            |  pool: 5
            |  timeout: 5000
            |#{env}:
            |  <<: *default
            YAML
          end

          it 'is valid' do
            expect(subject).to be_empty
          end

          it_behaves_like 'valid configuration'
        end

        context 'when type is incorrect' do
          let(:margin_config) do
            <<-YAML
            |default: &default
            |  adapter: sqlite3
            |  pool: 5
            |  timeout: non-int
            |#{env}:
            |  <<: *default
            YAML
          end

          it 'has no errors' do
            expect(subject).not_to be_empty
          end

          it 'returns error' do
            expect(subject.first).to match(%r{/timeout.+not a integer.+})
          end

          it_behaves_like 'invalid configuration'
        end

        context 'when required option is missing' do
          let(:margin_config) do
            <<-YAML
            |default: &default
            |  pool: 5
            |#{env}:
            |  <<: *default
            YAML
          end

          it 'has no errors' do
            expect(subject).not_to be_empty
          end

          it 'returns error' do
            expect(subject.first).to match(/.+key 'adapter:'.+is required/)
          end

          it_behaves_like 'invalid configuration'
        end
      end
    end
  end
end
