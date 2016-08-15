require "bundler/setup"

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "simplecov"
SimpleCov.start

require "dpn/bagit"
require "test/unit"
require "test_case"

