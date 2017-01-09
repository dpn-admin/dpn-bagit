require "dpn/bagit/bag"

##
# A wrapper for a serialized Bag-It bag on disk.
# Once created, will not change with changes made to the underlying filesystem
# bag; in that case, a new object should be created.
# @!attribute [r] location
#   @return [String] The location, which can be relative or absolute.
class DPN::Bagit::SerializedBag

  attr_reader :location

  # Create a SerializedBag
  # @param path [String] Path to the file.
  def initialize(path)
    raise ArgumentError, "File does not exist!" unless File.exist?(path)
    @location = path
  end

  # Returns the file name for the serialized bag, without it's extension.
  # @return [String] name
  def name
    @name ||= File.basename(location, File.extname(location))
  end

  # Returns the directory path to the serialized bag.
  # @return [String] path
  def path
    @path ||= File.dirname(location)
  end

  # Returns the size of the serialized bag (in bytes).
  # @return [Fixnum] size
  def size
    File.size(location)
  end

  # Returns the fixity of the serialized version of the bag.
  # @param algorithm [Symbol] The algorithm to use for calculation.
  # @return [String] fixity
  def fixity(algorithm)
    @cachedFixity ||= begin
      case algorithm
      when :sha256
        digest = Digest::SHA256
      else
        raise ArgumentError, "Unknown algorithm."
      end
      digest.file(location).hexdigest
    end
  end

  # Unserialize the bag into the local filesystem.  This object
  # is unchanged.  Requires sufficient permissions and disk space.
  # @return [DPN::Bagit::Bag] A bag made from the unserialized object.
  def unserialize!
    `/bin/tar -xf #{location} -C #{path} 2> /dev/null`
    raise RuntimeError, "cannot untar #{location}" unless $?.success?
    DPN::Bagit::Bag.new(File.join(path, name))
  end
end
