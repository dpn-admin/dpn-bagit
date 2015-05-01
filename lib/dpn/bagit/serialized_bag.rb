require "dpn/bagit/bag"


# A wrapper for a serialized Bag-It bag on disk.
# Once created, will not change with changes made to the underlying filesystem
# bag; in that case, a new object should be created.
class DPN::Bagit::SerializedBag

  # Create a SerializedBag
  # @param _location [String] Path to the file.
  def initialize(_location)
    if File.exists?(_location) == false
      raise ArgumentError, "File does not exist!"
    end

    @location = _location
    @cachedFixity = nil
  end


  # Returns the size of the serialized bag.
  # @return [Fixnum] Apparent size of the bag in bytes.
  def size()
    return File.size(@location)
  end


  # Returns the local file location of the Bag.
  # @return [String] The location, which can be relative or absolute.
  def location()
    return @location
  end


  # Returns the fixity of the serialized version of the bag.
  # @param algorithm [Symbol] The algorithm to use for calculation.
  # @return [String] The fixity of the file.
  def fixity(algorithm)
    if @cachedFixity == nil
      case algorithm
      when :sha256
        digest = Digest::SHA256
      else
        raise ArgumentError, "Unknown algorithm."
      end

      @cachedFixity = digest.file(@location).hexdigest
    end
    return @cachedFixity
  end


  # Unserialize the bag into the local filesystem.  This object
  # is unchanged.  Requires sufficient permissions and disk space.
  # @return [Bag] A bag made from the unserialized object.
  def unserialize!()
    `/bin/tar -xf #{@location} -C #{File.dirname(@location)}`
    name = File.basename(@location).to_s.sub(/\..*/,'')    # remove the file extension
    return DPN::Bagit::Bag.new(File.join(File.dirname(@location), name))
  end
end
