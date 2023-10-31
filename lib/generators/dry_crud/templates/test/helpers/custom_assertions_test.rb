require 'test_helper'
require 'support/custom_assertions'
require 'support/crud_test_helper'
require 'support/crud_test_model'

# Test CustomAssertions
class CustomAssertionsTest < ActiveSupport::TestCase

  include CustomAssertions
  include CrudTestHelper

  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db

  test 'assert count succeeds if count matches' do
    assert_nothing_raised do
      assert_count 3, 'ba', 'barbabapa'
    end
  end

  test 'assert count succeeds if count is zero' do
    assert_nothing_raised do
      assert_count 0, 'bo', 'barbabapa'
    end
  end

  test 'assert count fails if count does not match' do
    assert_raise(Minitest::Assertion) do
      assert_count 2, 'ba', 'barbabapa'
    end
  end

  test 'assert valid record succeeds' do
    assert_nothing_raised do
      assert_valid crud_test_models('AAAAA')
    end
  end

  test 'assert valid record fails for invalid' do
    assert_raise(Minitest::Assertion) do
      assert_valid invalid_record
    end
  end

  test 'assert not valid succeeds if record invalid' do
    assert_nothing_raised do
      assert_not_valid invalid_record
    end
  end

  test 'assert not valid succeds if record invalid and invalid attrs given' do
    assert_nothing_raised do
      assert_not_valid invalid_record, :name, :rating
    end
  end

  test 'assert not valid fails if record valid' do
    assert_raise(Minitest::Assertion) do
      assert_not_valid crud_test_models('AAAAA')
    end
  end

  test 'assert not valid fails if record invalid and valid attrs given' do
    assert_raise(Minitest::Assertion) do
      assert_not_valid invalid_record, :name, :rating, :children
    end
  end

  test 'assert not valid fails if not all invalid attrs given' do
    assert_raise(Minitest::Assertion) do
      assert_not_valid invalid_record, :name
    end
  end

  private

  def invalid_record
    m = crud_test_models('AAAAA')
    m.name = nil
    m.rating = 42
    m
  end

end
