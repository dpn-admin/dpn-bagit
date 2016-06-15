require "dpn/bagit/settings"

class DPN::Bagit::Bag
  # A wrapper for the dpn-info.txt file within the bag.  Once created, it does not change with
  # changes made to the underlying txt file; in that case, a new Bag should be created.
  # @private
  class DPNInfoTxt

    # @overload initialize(file_location)
    #   Build a DPNInfoText from an existing dpn-info.txt file.
    #   @param [String] file_location The location of the existing dpn-info.txt.
    # @overload initialize(opts)
    #   Build a DPNInfoText from scratch by supplying an options hash.
    #   @param [Hash] opts
    #   @option opts [String] :dpnObjectID
    #   @option opts [String] :localName
    #   @option opts [String] :ingestNodeName
    #   @option opts [String] :ingestNodeAddress
    #   @option opts [String] :ingestNodeContactName
    #   @option opts [String] :ingestNodeContactEmail
    #   @option opts [Fixnum] :version
    #   @option opts [String] :firstVersionObjectID
    #   @option opts [String] :bagTypeName
    #   @option opts [Array<String>] :interpretiveObjectIDs
    #   @option opts [Array<String>] :rightsObjectIDs
    def initialize(opts)
      @settings = DPN::Bagit::Settings.instance.config
      @dpnInfoKeysArrays = @settings[:bag][:dpn_info][:arrays]
      @dpnInfoKeysNonArrays = @settings[:bag][:dpn_info][:non_arrays]
      @dpnInfoErrors = []
      @dpnInfo = {}
      if opts.is_a? String
        from_existing(opts)
      else
        build(opts)
      end
    end

    # Check for validity
    # @return [Boolean]
    def valid?
      @dpnInfoErrors.empty?
    end

    # Returns a list of any errors encountered on creation and validation.
    # @return [Array<String]
    def getErrors
      @dpnInfoErrors
    end

    # Get the value associated with the given field.
    # @param key [Symbol]
    def [](key)
      @dpnInfo[key.to_sym]
    end

    protected

      def build(opts)
        (@dpnInfoKeysNonArrays + @dpnInfoKeysArrays).each do |key|
          key = key.to_sym
          @dpnInfo[key] = opts[key]
        end
      end

      def from_existing(file_location)
        @dpnInfoKeysArrays.each do |key|
          @dpnInfo[key.to_sym] = []
        end

        if File.exist?(file_location)
          if File.readable?(file_location)
            contents = File.read(file_location)

            @dpnInfoKeysNonArrays.each do |key|
              key = key.to_sym	#does nothing if settings correctly configured
              pattern = @settings[:bag][:dpn_info][key][:regex] + @settings[:bag][:dpn_info][:capture]
              regex = Regexp.new(pattern)
              match = regex.match(contents)
              if match.nil? || match[1].nil?
                @dpnInfoErrors.push("dpn-info.txt does not have the tag #{@settings[:bag][:dpn_info][key][:name]}")
              else
                @dpnInfo[key] = match[1]
              end

              if @dpnInfo[key].respond_to?(:strip!)
                @dpnInfo[key].strip!
                @dpnInfo[key].downcase!
              end
            end

            @dpnInfoKeysArrays.each do |key|
              key = key.to_sym	#does nothing if settings correctly configured
              pattern = @settings[:bag][:dpn_info][key][:regex] + @settings[:bag][:dpn_info][:capture]
              regex = Regexp.new(pattern)
              if regex.match(contents).nil?
                @dpnInfoErrors.push("dpn-info.txt does not have the tag #{@settings[:bag][:dpn_info][key][:name]}")
                @dpnInfo[key] = []
              else
                @dpnInfo[key] = contents.scan(regex)
                @dpnInfo[key].flatten!
                @dpnInfo[key].each_index do |i|
                  @dpnInfo[key][i].strip!
                  @dpnInfo[key][i].downcase!
                  @dpnInfo[key].delete_at(i) if @dpnInfo[key][i] == ''
                end
              end
            end
          else
            @dpnInfoErrors.push("dpn-info.txt exists, but cannot be opened for reading.")
          end

        else
          @dpnInfoErrors.push("dpn-info.txt cannot be found.")
        end
      end

  end
end
