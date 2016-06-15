require "find"
require "dpn/bagit/settings"
require "dpn/bagit/ext/bagit"
require "dpn/bagit/uuidv4_validator"
require "dpn/bagit/bag/dpn_info_txt"

# A wrapper for an unserialized Bag-It bag on disk.  Does not support serialized bags.
# Once created, a Bag object will not change with changes made to the underlying filesystem
# bag; in that case, a new Bag object should be created.
class DPN::Bagit::Bag
    private

      def initialize(_location)
        @settings = DPN::Bagit::Settings.instance.config
        @bag = ::BagIt::Bag.new(_location)
        @location = _location
        @cachedValidity = nil
        @cachedFixity = nil
        @cachedSize = nil
        @validationErrors = []
        @dpnObjectID = nil

        @dpnInfo = DPNInfoTxt.new(dpn_info_file_location)
        @dpnObjectID = @dpnInfo[:dpnObjectID]
        @dpnObjectID ||= File.basename(_location)
    end

  public

    # Get the net fixity of the Bag.
    # @param algorithm [Symbol] Algorithm to use.
    # @return [String] The fixity of the tagmanifest-<alg>.txt file.
    def fixity(algorithm)
      if @cachedFixity.nil?
        case algorithm
        when :sha256
          digest = Digest::SHA256
          path = File.join(@location, "tagmanifest-sha256.txt")
          if File.exist?(path)
            @cachedFixity = digest.file(path).hexdigest
          else
            @cachedFixity = ""
            @cachedValidity = false
          end
        else
          raise ArgumentError, "Unknown algorithm."
        end

      end
      @cachedFixity
    end

    # Returns the total size of the Bag.
    # @return [Fixnum] Apparent size of the Bag in bytes.
    def size
      if @cachedSize.nil?
        size = 0
        Find.find(location) do |f|
          size += File.size(f) if File.file?(f) || File.directory?(f)
        end
        @cachedSize = size
      end
      @cachedSize
    end

    # Returns the local file location of the Bag.
    # @return [String] The location, which can be relative or absolute.
    attr_reader :location

    # Returns the uuid of the bag, according to dpn-info.txt.
    # @return [String]
    def uuid
      @dpnObjectID
    end

    # Checks that all required files are present, no extraneous files are present, and all file digests
    # match manifests.
    # @return [Boolean] True if valid, false otherwise.
    def valid?
      if @cachedValidity.nil?
        @validationErrors.push(@bag.errors.full_messages) if @bag.valid? == false

        if File.exist?(@bag.fetch_txt_file) == true
          @validationErrors.push("The file fetch.txt is present and unsupported.")
        end

        if Pathname.new(@bag.bag_dir).basename.to_s != @dpnInfo[:dpnObjectID]
          @validationErrors.push("The name of the root directory does not match the #{@settings[:bag][:dpn_info][:dpnObjectID][:name]}.")
        end

        if File.exist?(@bag.manifest_file("sha256")) == true
          if File.readable?(@bag.manifest_file("sha256")) == false
            @validationErrors.push("The file manifest-sha256.txt exists but cannot be read.")
          end
        else
          @validationErrors.push("The file manifest-sha256.txt does not exist.")
        end

        if File.exist?(@bag.tagmanifest_file("sha256")) == true
          if File.readable?(@bag.tagmanifest_file("sha256")) == false
            @validationErrors.push("The file tagmanifest-sha256.txt exists but cannot be read.")
          end
        else
          @validationErrors.push("The file tagmanifest-sha256.txt does not exist.")
        end

        @validationErrors.push("Version must be > 0.") if @dpnInfo[:version].to_i <= 0

        uuidValidator = DPN::Bagit::UUID4Validator.new(true)
        if uuidValidator.isValid?(@dpnInfo[:dpnObjectID]) == false
          @validationErrors.push("#{@settings[:bag][:dpn_info][:dpnObjectID][:name]} with value \"#{@dpnInfo[:dpnObjectID]}\" is not a valid UUIDv4.")
        end

        if uuidValidator.isValid?(@dpnInfo[:firstVersionObjectID]) == false
          @validationErrors.push("#{@settings[:bag][:dpn_info][:firstVersionObjectID][:name]} with value \"#{@dpnInfo[:firstVersionObjectID]}\" is not a valid UUIDv4.")
        end

        @dpnInfo[:rightsObjectIDs].each do |id|
          if uuidValidator.isValid?(id) == false
            @validationErrors.push("#{@settings[:bag][:dpn_info][:rightsObjectIDs][:name]} value of \"#{id}\" is not a valid UUIDv4.")
          end
        end

        @dpnInfo[:interpretiveObjectIDs].each do |id|
          if uuidValidator.isValid?(id) == false
            @validationErrors.push("#{@settings[:bag][:dpn_info][:interpretiveObjectIDs][:name]} value of \"#{id}\" is not a valid UUIDv4.")
          end
        end

        @cachedValidity = if @validationErrors.empty? == true && @dpnInfo.getErrors.empty? == true
                            true
                          else
                            false
                          end
      end

      @cachedValidity
    end

    # Returns validation errors.  The list is not populated until a call to {#isValid?} has been made.
    # @return [Array<String>] The errors.
    def errors
      @dpnInfo.getErrors + @validationErrors
    end

    # Returns true if the Bag contains no files.
    # @return [Boolean] True if empty, false otherwise.
    def empty?
      @bag.empty?
    end

  protected

    # Get the path of the dpn-info.txt file for this bag.
    # @return [String]
    def dpn_info_file_location
      File.join(@bag.bag_dir, @settings[:bag][:dpn_dir], @settings[:bag][:dpn_info][:name])
    end
end
