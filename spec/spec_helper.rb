require 'rubygems'

if ENV['COVERAGE']
  require 'simplecov'
  require 'simplecov-rcov'
  require 'simplecov-rcov-text'
  require 'codeclimate-test-reporter'

  SimpleCov.add_filter '/spec/'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter,
    SimpleCov::Formatter::RcovTextFormatter,
    CodeClimate::TestReporter::Formatter,
  ]
  SimpleCov.start
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rails_config_validator'
