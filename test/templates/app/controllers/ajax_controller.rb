# encoding: UTF-8

# Crud controller responding to js as well
class AjaxController < CrudController

  def ajax

  end

  def update
    super do |format, _success|
      format.js
    end
  end

end
