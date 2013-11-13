# encoding: UTF-8

# Crud controller responding to js as well
class AjaxController < CrudController

  respond_to :html, :json, :js

  def ajax

  end

end
