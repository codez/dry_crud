class CitiesController < AjaxController
  
  def show
    respond_to do |format|
      format.html do
        flash[:notice] = flash[:notice]
        redirect_to :action => 'index'
      end
      format.xml  { render :xml => @entry }
    end
  end

end