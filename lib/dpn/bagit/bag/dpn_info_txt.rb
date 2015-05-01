require "dpn/bagit/settings"

class DPN::Bagit::Bag
  # A wrapper for the dpn-info.txt file within the bag.  Once created, it does not change with
  # changes made to the underlying txt file; in that case, a new Bag should be created.
  # @private
  class DPNInfoTxt
    private
      def initialize(fileLocation)
        @settings = DPN::Bagit::Settings.instance.config
        @dpnInfoKeysArrays = @settings[:bag][:dpn_info][:arrays]
        @dpnInfoKeysNonArrays = @settings[:bag][:dpn_info][:non_arrays]
        @dpnInfoErrors = []
        @dpnInfo = {}
        self.validate!(fileLocation)
      end

    protected
      def validate!(fileLocation)
        @dpnInfoKeysArrays.each do |key|
          @dpnInfo[key.to_sym] = []
        end

        if File.exists?(fileLocation)
          if File.readable?(fileLocation)
            contents = nil
            File.open(fileLocation, 'r') do |file|
              contents = file.read
            end

            @dpnInfoKeysNonArrays.each do |key|
              key = key.to_sym	#does nothing if settings correctly configured
              pattern  = @settings[:bag][:dpn_info][key][:regex] + @settings[:bag][:dpn_info][:capture]
              regex = Regexp.new(pattern)
              match = regex.match(contents)
              if match == nil or match[1] == nil
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
              pattern  = @settings[:bag][:dpn_info][key][:regex] + @settings[:bag][:dpn_info][:capture]
              regex = Regexp.new(pattern)
              if regex.match(contents) == nil
                @dpnInfoErrors.push("dpn-info.txt does not have the tag #{@settings[:bag][:dpn_info][key][:name]}")
                @dpnInfo[key] = []
              else
                @dpnInfo[key] = contents.scan(regex)
                @dpnInfo[key].flatten!
                @dpnInfo[key].each_index do |i|
                  @dpnInfo[key][i].strip!
                  @dpnInfo[key][i].downcase!
                  if @dpnInfo[key][i] == ''
                    @dpnInfo[key].delete_at(i)
                  end
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

    public
      # Returns a list of any errors encountered on creation and validation.
      # @return [Array<String]
      def getErrors()
        return @dpnInfoErrors
      end

      # Get the value associated with the given field.
      # @param key [Symbol]
      def [](key)
        return @dpnInfo[key.to_sym]
      end
  end
end
