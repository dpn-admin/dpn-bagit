require 'bagit'

module BagIt
	module Validity
		def consistent?
			(manifest_files|tagmanifest_files).each do |mf|
				# get the algorithm implementation
				readAlgo = /manifest-(.+).txt$/.match(File.basename(mf))[1]
				algo = case readAlgo
						  when /sha1/i
							  Digest::SHA1
						  when /md5/i
							  Digest::MD5
						  when /sha256/i
							  Digest::SHA256
						  when /sha384/i
							  Digest::SHA384
						  when /sha512/i
							  Digest::SHA512
						  else
							  errors.add :consistency, "Algorithm #{readAlgo} is invalid or unsupported."
							  return false
					  end
				# Check every file in the manifest
				File.open(mf) do |io|
					io.each_line do |line|
						expected, path = line.chomp.split(/\s+/, 2)
						file = File.join(bag_dir, path)
						if File.exist? file
							actual = algo.file(file).hexdigest
							if expected != actual
								errors.add :consistency, "expected #{file} to have #{algo}: #{expected}, actual is #{actual}"
							end
						end
					end
				end
			end


			errors.on(:consistency).nil?
		end
	end
end