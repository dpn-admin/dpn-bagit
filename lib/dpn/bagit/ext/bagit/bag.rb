require 'bagit/fetch'
require 'bagit/file'
require 'bagit/info'
require 'bagit/manifest'
require 'bagit/string'
require 'bagit/valid'

module BagIt

  # Represents the state of a bag on a filesystem
  class Bag

    # Return the paths to each bag file relative to bag_dir
    def bag_files
      Dir.glob(File.join(data_dir, '**', '*'), File::FNM_DOTMATCH).select { |f| File.file? f }
    end
  end
end
