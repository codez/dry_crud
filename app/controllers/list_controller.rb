# encoding: UTF-8

class ListController < ApplicationController

  include DryCrud::GenericModel
  include DryCrud::Nestable
  include DryCrud::Rememberable
  include DryCrud::RenderCallbacks
  include DryCrud::ListActions

  # Include these modules after the #list_entries method is defined.
  include DryCrud::Searchable
  include DryCrud::Sortable

  respond_to :html, :json

  define_render_callbacks :index

end