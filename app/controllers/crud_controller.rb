# encoding: UTF-8

# Abstract controller providing basic CRUD actions.
#
# Some enhancements were made to ease extensibility.
# The current model entry is available in the view as an instance variable
# named after the +model_class+ or in the helper method +entry+.
# Several protected helper methods are there to be (optionally) overriden by
# subclasses.
# With the help of additional callbacks, it is possible to hook into the
# action procedures without overriding the entire method.
class CrudController < ListController

  # All actions are extracted to this module to ease extensibility.
  # Keep this include and override any methods afterwards.
  include DryCrud::CrudActions

end
