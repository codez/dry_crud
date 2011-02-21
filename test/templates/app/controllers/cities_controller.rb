class CitiesController < AjaxController

  def show
    respond_to do |format|
      format.html do
        flash.keep
        redirect_to_index
      end
      format.xml  { render :xml => @entry }
    end
  end

end