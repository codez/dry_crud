require 'test_helper'

class StandardFormBuilderTest < ActionView::TestCase
  
  # set dummy helper class for ActionView::TestCase
  self.helper_class = StandardHelper
  
  attr_reader :form
  
  def setup
    @table = StandardFormBuilder.new(:person, "foo", self, {})
  end
  
end