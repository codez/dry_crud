class Admin::CountriesController < AjaxController

  self.nesting = :admin

  self.search_columns = :name, :code

  def show
    super do |format|
      format.html { redirect_to index_url, flash.to_hash }
    end
  end

end