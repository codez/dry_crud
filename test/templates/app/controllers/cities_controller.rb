class CitiesController < AjaxController

  def show
    respond_to do |format|
      format.html { redirect_to_index flash }
      format.xml  { render :xml => @entry }
    end
  end

end