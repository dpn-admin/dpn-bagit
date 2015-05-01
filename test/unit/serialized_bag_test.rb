require "test_helper"

class SerializedBagTest < TestCase

     # Called before every test method runs. Can be used
     # to set up fixture information.
     def setup
          super()
          @settings = DPN::Bagit::Settings.instance
          @location = File.join(@settings[:root],'test', 'test_objects/serialized_bag_test/supplies/a7b18eb0-005f-11e3-8ebb-f23c91aec05e.tar')
          @sandbox = File.join(@settings[:root], 'test', 'test_objects/serialized_bag_test/sandbox/')
          if File.exists?(@sandbox) == false
               FileUtils.mkdir_p(@sandbox)
          end
     end

     # Called after every test method runs. Can be used to tear
     # down fixture information.

     def teardown
          FileUtils.rm_rf(File.join(@sandbox, '*'))
     end

     def test_init()
          serializedBag = DPN::Bagit::SerializedBag.new(@location)
          assert(serializedBag != nil, "init failed")
     end


     def test_getLocation
          bag = DPN::Bagit::SerializedBag.new(@location)
          assert(bag.getLocation() == @location, "location mismatch")
     end


     def test_getSize
          bag = DPN::Bagit::SerializedBag.new(@location)
          size  = bag.getSize()
          assert(size < 9921061 * 1.1, "size greater than expected * 1.1")
          assert(size > 9921061 * 0.9, "size less than expected * 0.9")
     end


     def test_getFixity
          bag = DPN::Bagit::SerializedBag.new(@location)
          fixity = '321a4266ffed6add184b6998624747e174be384933ca2fc699502dfcd039f765'
          assert_equal(fixity, bag.getFixity(:sha256))
     end


     def test_unserialize
          FileUtils.cp(@location, @sandbox)
          serializedBag = DPN::Bagit::SerializedBag.new(File.join(@sandbox, File.basename(@location)))
          bag = serializedBag.unserialize!()
          assert(bag.valid?, "unserialized bag version isn't valid.")
     end



end