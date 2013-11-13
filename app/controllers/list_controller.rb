# encoding: UTF-8

# Abstract controller providing a basic list action.
# The loaded model entries are available in the view as an instance variable
# named after the +model_class+ or by the helper method +entries+.
#
# The +index+ action lists all entries of a certain model and provides
# functionality to search and sort this list.
# Furthermore, it remembers the last search and sort parameters after the
# user returns from a displayed or edited entry.
class ListController < ApplicationController

  include DryCrud::GenericModel
  include DryCrud::Nestable
  include DryCrud::Rememberable
  include DryCrud::RenderCallbacks

  # All actions are extracted to this module to ease extensibility.
  # Keep this include and override any methods afterwards.
  include DryCrud::ListActions

  # Include these modules after the #list_entries method is defined.
  include DryCrud::Searchable
  include DryCrud::Sortable

  respond_to :html, :json

  define_render_callbacks :index

end
