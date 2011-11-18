class CitiesController < AjaxController

  def show
    respond_to do |format|
      format.html { redirect_to_index flash.to_hash }
      format.xml  { render :xml => @entry }
    end
  end

end