class Admin::CountriesController < AjaxController

  self.nesting = :admin

  self.search_columns = :name, :code

  def show
    super do |format|
      format.html { redirect_to index_path, flash.to_hash }
    end
  end
  
  protected
  
  def show_path
    index_path
  end

end