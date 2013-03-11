class Admin::CountriesController < AjaxController

  self.nesting = :admin

  self.search_columns = :name, :code

  self.permitted_attrs = [:name, :code]

  self.default_sort = 'countries.name'

  def show
    super do |format|
      format.html { redirect_to index_url, flash.to_hash }
    end
  end

end