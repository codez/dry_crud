require 'test_helper'
require 'custom_assertions'
require 'crud_test_model'

class CustomAssertionsTest < ActiveSupport::TestCase

  include CustomAssertions

  include CrudTestHelper
  
  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db
  
  test "assert include succeeds if included" do
    assert_nothing_raised do
      assert_include [1,2,3], 2
    end
  end
  
  test "assert include succeeds if record included" do
    assert_nothing_raised do
      assert_include CrudTestModel.all, crud_test_models("AAAAA")
    end
  end
  
  test "assert include fails if not included" do
    assert_raise(Test::Unit::AssertionFailedError) do
      assert_include [1,2,3], 5
    end
  end
  
  test "assert not include succeeds if not included" do
    assert_nothing_raised do
      assert_not_include [1,2,3], 5
    end
  end
  
  test "assert not include fails if included" do
    assert_raise(Test::Unit::AssertionFailedError) do
      assert_not_include [1,2,3], 3
    end
  end
  
  test "assert count succeeds if count matches" do
    assert_nothing_raised do
      assert_count 3, "ba", "barbabapa"
    end
  end
  
  test "assert count succeeds if count is zero" do
    assert_nothing_raised do
      assert_count 0, "bo", "barbabapa"
    end
  end
  
  test "assert count fails if count does not match" do
    assert_raise(Test::Unit::AssertionFailedError) do
      assert_count 2, "ba", "barbabapa"
    end
  end
  
  test "assert valid record succeeds" do
    assert_nothing_raised do
      assert_valid crud_test_models("AAAAA")
    end
  end

  test "assert valid record fails for invalid" do
    assert_raise(Test::Unit::AssertionFailedError) do
      assert_valid invalid_record
    end
  end
  
  test "assert not valid succeeds if record invalid" do
    assert_nothing_raised do
      assert_not_valid invalid_record
    end
  end
  
  test "assert not valid succeds if record invalid and invalid attrs given" do
    assert_nothing_raised do
      assert_not_valid invalid_record, :name, :rating
    end
  end
  
  test "assert not valid fails if record valid" do
    assert_raise(Test::Unit::AssertionFailedError) do
      assert_not_valid crud_test_models("AAAAA")
    end
  end
  
  test "assert not valid fails if record invalid and valid attrs given" do
    assert_raise(Test::Unit::AssertionFailedError) do
      assert_not_valid invalid_record, :name, :rating, :children
    end
  end
  
  test "assert not valid fails if record invalid and not all invalid attrs given" do
    assert_raise(Test::Unit::AssertionFailedError) do
      assert_not_valid invalid_record, :name
    end
  end
  
  private
  
  def invalid_record
    m = crud_test_models("AAAAA")
    m.name = nil
    m.rating = 42
    m
  end
  
end
