require "bundler/setup"
require "configliere"
require "singleton"

# A class that manages the various settings required by dpn-bagit.
class DPN::Bagit::Settings
  include ::Singleton

  def initialize
    @config = nil
    config
  end

  def config
    if @config.nil?
      @config = Configliere::Param.new
      @config[:root] = get_project_root
      @config.read File.join @config[:root], "/lib/dpn/bagit/defaults.config.yml"
      @config.resolve!
    end
    @config
  end

  def [](key)
    config[key]
  end

  def []=(key, value)
    config[key] = value
  end

  protected

    # Get the path to the project root.
    def get_project_root
      Bundler.rubygems.find_name('dpn-bagit').first.full_gem_path
    end

end
