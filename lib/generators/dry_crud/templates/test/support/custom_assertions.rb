# encoding: UTF-8

# A handful of convenient assertions. The aim of custom assertions is to
# provide more specific error messages and to perform complex checks.
#
# Ideally, include this module into your test_helper.rb file:
#  # at the beginning of the file:
#  require 'support/custom_assertions'
#
#  # inside the class definition:
#  include CustomAssertions
module CustomAssertions

  # Asserts that regexp occurs exactly expected times in string.
  def assert_count(expected, regexp, string, msg = '')
    actual = string.scan(regexp).size
    msg = message(msg) do
      "Expected #{mu_pp(regexp)} to occur #{expected} time(s), " +
      "but occured #{actual} time(s) in \n#{mu_pp(string)}"
    end
    assert expected == actual, msg
  end

  # Asserts that the given active model record is valid.
  # This method used to be part of Rails but was deprecated, no idea why.
  def assert_valid(record, msg = '')
    record.valid?
    msg = message(msg) do
      "Expected #{mu_pp(record)} to be valid, " +
      "but has the following errors:\n" +
      mu_pp(record.errors.full_messages.join("\n"))
    end
    assert record.valid?, msg
  end

  # Asserts that the given active model record is not valid.
  # If you provide a set of invalid attribute symbols, all of and only these
  # attributes are expected to have errors. If no invalid attributes are
  # specified, only the invalidity of the record is asserted.
  def assert_not_valid(record, *invalid_attrs)
    msg = message do
      "Expected #{mu_pp(record)} to be invalid, but is valid."
    end
    assert !record.valid?, msg

    if invalid_attrs.present?
      assert_invalid_attrs_have_errors(record, *invalid_attrs)
      assert_other_attrs_have_no_errors(record, *invalid_attrs)
    end
  end

  # The method used to by Test::Unit to format arguments.
  # Prints ActiveRecord objects in a simpler format.
  def mu_pp(obj)
    if obj.is_a?(ActiveRecord::Base) #:nodoc:
      obj.to_s
    else
      super
    end
  end

  private

  def assert_invalid_attrs_have_errors(record, *invalid_attrs)
    invalid_attrs.each do |a|
      msg = message do
        "Expected attribute #{mu_pp(a)} to be invalid, but is valid."
      end
      assert record.errors[a].present?, msg
    end
  end

  def assert_other_attrs_have_no_errors(record, *invalid_attrs)
    record.errors.each do |a, error|
      msg = message do
        "Attribute #{mu_pp(a)} not declared as invalid attribute, " +
        "but has the following error(s):\n#{mu_pp(error)}"
      end
      assert invalid_attrs.include?(a), msg
    end
  end

end
