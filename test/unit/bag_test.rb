require "test_helper"


class BagTest < TestCase

	# Called before every test method runs. Can be used
	# to set up fixture information.
	def setup
		super()
    @settings = DPN::Bagit::Settings.instance
		@location = File.join(@settings[:root], 'test', 'test_objects/bag_test/supplies/a7b18eb0-005f-11e3-8ebb-f23c91aec05e')
		@emptyLocation = File.join(@settings[:root], 'test', 'test_objects/bag_test/supplies/a7b18eb0-005f-11e3-8ebb-asdfasdfasdf')
	end

	# Called after every test method runs. Can be used to tear
	# down fixture information.

	def teardown
		# Do nothing
	end

	def test_buildGoodBag
		bag = DPN::Bagit::Bag.new(@location)
		assert(bag != nil, "init failed")
	end

	def test_isValid1
		bag = DPN::Bagit::Bag.new(@location)
		assert(bag.isValid? == true, "expected bag to be valid\n#{bag.getErrors.join('\n')}")
	end

	def test_getErrors1
		bag = DPN::Bagit::Bag.new(@location)
		assert(bag.getErrors == [], "expected empty array")
	end

	def test_getFixity1
		bag = DPN::Bagit::Bag.new(@location)
		fixity = 'c06bc0e67e8bf9ed0c0b2dc9f5990c2309ce41c7e2386a15025228e2ec2c9649'
		assert(bag.getFixity(:sha256) == fixity, "fixity mismatch")
	end

	def test_getLocation
		bag = DPN::Bagit::Bag.new(@location)
		assert(bag.getLocation() == @location, "location mismatch")
	end

	def test_getUUID
		bag = DPN::Bagit::Bag.new(@location)
		assert(bag.getUUID() == 'a7b18eb0-005f-11e3-8ebb-f23c91aec05e', "uuid mismatch")
	end

	def test_getSize
		bag = DPN::Bagit::Bag.new(@location)
		size  = bag.getSize()
    assert(size < 9921061 * 1.1, "size greater than expected * 1.1")
    assert(size > 9921061 * 0.9, "size less than expected * 0.9")
	end

	def test_isEmptyFalse
		bag = DPN::Bagit::Bag.new(@location)
		assert(bag.isEmpty?() == false, "expected bag.isEmpty? == false")
	end

	def test_getUUIDFromEmptyBag
		bag = DPN::Bagit::Bag.new(@emptyLocation)
		assert(bag.isValid? == false, "Bag should not be valid.")
		assert(bag.isEmpty? == true, "This bag is empty!")
		assert_equal('a7b18eb0-005f-11e3-8ebb-asdfasdfasdf', bag.getUUID, "Even this bag should have a uuid.")
	end


end