require "bundler/setup"

# We require our monkey patch in this exact location
# in order to play nice with Rails autoloading.
require "bagit"
require "dpn/bagit/ext/bagit"

require "dpn/bagit/version"
require "dpn/bagit/bag"
require "dpn/bagit/serialized_bag"
require "dpn/bagit/settings"
require "dpn/bagit/uuidv4_validator"

module DPN
  module Bagit
    # Your code goes here...
  end
end
