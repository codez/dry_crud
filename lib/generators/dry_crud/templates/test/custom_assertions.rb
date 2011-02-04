# A handful of convenient assertions. The aim of custom assertions is to
# provide more specific error messages and to perform complex checks.
#
# Ideally, include this module into your test_helper.rb file:
#  # at the beginning of the file:
#  require 'custom_assertions'
#  
#  # inside the class definition:
#  include CustomAssertions
module CustomAssertions
  
  # Asserts that the element is included in the collection.
  def assert_include(collection, element, message = "")
    full_message = build_message(message, "<?> expected to be included in \n<?>.", 
                                 element, collection)
    assert_block(full_message) { collection.include?(element) }
  end
    
  # Asserts that the element is not included in the collection.
  def assert_not_include(collection, element, message = "")
    full_message = build_message(message, "<?> expected not to be included in \n<?>.", 
                                 element, collection)
    assert_block(full_message) { !collection.include?(element) }
  end
  
  # Asserts that regexp occurs exactly expected times in string.
  def assert_count(expected, regexp, string, message = "")
    actual = string.scan(regexp).size
    full_message = build_message(message, "<?> expected to occur ? time(s), but occured ? time(s) in \n<?>.", 
                                 regexp, expected, actual, string)
    assert_block(full_message) { expected == actual }
  end
  
  # Asserts that the given active model record is valid.
  # This method used to be part of Rails but was deprecated, no idea why.
  def assert_valid(record, message = "")
    record.valid?
    full_message = build_message(message, 
        "? expected to be valid, but has the following errors: \n ?.", 
       record, record.errors.full_messages.join("\n"))
    assert_block(full_message) { record.valid? }
  end
  
  # Asserts that the given active model record is not valid.
  # If you provide a set of invalid attribute symbols, all of and only these
  # attributes are expected to have errors. If no invalid attributes are
  # specified, only the invalidity of the record is asserted.
  def assert_not_valid(record, *invalid_attrs)
    message = build_message("", "? expected to be invalid, but is valid.", record)
    assert_block(message) { !record.valid? }
    
    # assert that the given attributes have errors.
    invalid_attrs.each do |a|
      message = build_message("", "Attribute <?> expected to be invalid, but is valid.", a)
      assert_block(message) { record.errors[a].present? }
    end
    
    if invalid_attrs.present?
      # assert that no other than the invalid attributes have errors.
      record.errors.each do |a, error|
        message = build_message("", "Attribute <?> not declared as invalid attribute, but has the following error: \n?.", a, error)
        assert_block(message) { invalid_attrs.include?(a) }
      end
    end
  end
  
end
