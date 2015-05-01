# A class that validates whether a string is a v4 UUID or not.
class DPN::Bagit::UUID4Validator
  # Create a new validator.
  # @param dashes [Boolean, NilClass]
  #    If set to true, dashes are required.
  #    If set to false, dashes are disallowed.
  #    If set to nil, dashes are optional.
  # @return [UUID4Validator]
  def initialize(dashes = nil)
    if dashes == nil
      @pattern = /^[A-Fa-f0-9]{8}-?[A-Fa-f0-9]{4}-?[A-Fa-f0-9]{4}-?[A-Fa-f0-9]{4}-?[A-Fa-f0-9]{12}\Z/
    elsif dashes == true
      @pattern = /^[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}\Z/
    else
      @pattern = /^[A-Fa-f0-9]{8}[A-Fa-f0-9]{4}[A-Fa-f0-9]{4}[A-Fa-f0-9]{4}[A-Fa-f0-9]{12}\Z/
    end
  end

  # Check if the given string is valid according to this validator.
  # This test is case-insensitive.
  # @param uuid [String] The uuid to test.
  # @return [Boolean]
  def isValid?(uuid)
    if @pattern.match(uuid)
      #matches a v4 uuid, case-insensitive, with or without dashes.
      return true
    else
      return false
    end
  end
end
