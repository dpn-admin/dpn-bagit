require "bundler/setup"
require "configliere"
require "test/unit"
require "dpn/bagit/settings"

class TestCase < Test::Unit::TestCase
	class << self
		def startup
      @@staticSettings = Configliere::Param.new(DPN::Bagit::Settings.instance.config.to_hash)
		end
	end

	def setup
    DPN::Bagit::Settings.instance.config.clear()
		DPN::Bagit::Settings.instance.config.merge!(@@staticSettings)
	end
end