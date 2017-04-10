
[![Build Status](https://travis-ci.org/dpn-admin/dpn-bagit.svg?branch=master)](https://travis-ci.org/dpn-admin/dpn-bagit) [![Code Climate](https://codeclimate.com/github/dpn-admin/dpn-bagit/badges/gpa.svg)](https://codeclimate.com/github/dpn-admin/dpn-bagit) [![Test Coverage](https://codeclimate.com/github/dpn-admin/dpn-bagit/badges/coverage.svg)](https://codeclimate.com/github/dpn-admin/dpn-bagit/coverage)

# DPN::Bagit
![dpn_bagit](https://cloud.githubusercontent.com/assets/26936378/24721060/1aa4be40-1a0d-11e7-89f1-3310507810dc.jpg)

## Description

A ruby implementation of the DPN BagIt spec, which is itself an extension of the
[BagIt spec](https://confluence.ucop.edu/display/Curation/BagIt).  Built on top of
[tipr/bagit](https://github.com/tipr/bagit).

This project is currently quite rough.  At present, only deserialization from .tar
and validation work.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dpn-bagit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dpn-bagit

## Usage

```ruby
require 'dpn-bagit'

bag = DPN::Bagit::Bag.new(location_of_bag)
if bag.empty? == false
  if bag.valid?
    fixity = bag.fixity
    uuid = bag.uuid
    size = bag.size
  else
    puts bag.errors
  end
end


bag = DPN::Bagit::SerializedBag.new(location_of_tarball).unserialize!
```


## Contributing

1. Fork it ( https://github.com/malakai97/dpn-bagit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
