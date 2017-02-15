require "test_helper"


class HiddenFilesTest < TestCase

	# Called before every test method runs. Can be used
	# to set up fixture information.
	def setup
		super()
    @settings = DPN::Bagit::Settings.instance
	  @uuid = "2fced019-7385-4532-8e76-d6cdccd09a12"
    @location = File.join(@settings[:root], 'test', 'test_objects/hidden_files_test/supplies', @uuid)
	end

	# Called after every test method runs. Can be used to tear
	# down fixture information.

	def teardown
		# Do nothing
	end

	def test_buildGoodBag
		bag = DPN::Bagit::Bag.new(@location)
		assert_not_nil(bag, "init failed")
	end

	def test_isValid1
		bag = DPN::Bagit::Bag.new(@location)
		assert(bag.valid? == true, "expected bag to be valid\n#{bag.errors.join('\n')}")
	end

	def test_getErrors1
		bag = DPN::Bagit::Bag.new(@location)
    assert_equal([], bag.errors, "expected empty array")
	end

	def test_getFixity1
		bag = DPN::Bagit::Bag.new(@location)
		fixity = '27e2bfadb9463faf92bf207d7e7288e5cb1dd3a4c221435aed9fedd08a0c8baf'
    assert_equal(fixity, bag.fixity(:sha256), "fixity_mismatch")
	end

	def test_getLocation
		bag = DPN::Bagit::Bag.new(@location)
		assert_equal(@location, bag.location(), "location mismatch")
	end

	def test_getUUID
		bag = DPN::Bagit::Bag.new(@location)
		assert_equal(@uuid, bag.uuid(), "uuid mismatch")
	end

	def test_getSize
		bag = DPN::Bagit::Bag.new(@location)
		size  = bag.size()
    assert(size < 9921061 * 1.1, "size greater than expected * 1.1")
    assert(size > 9921061 * 0.9, "size less than expected * 0.9")
	end

	def test_isEmptyFalse
		bag = DPN::Bagit::Bag.new(@location)
		assert(bag.empty?() == false, "expected bag.empty? == false")
	end

end
