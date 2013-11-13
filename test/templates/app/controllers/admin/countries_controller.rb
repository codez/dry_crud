# encoding: UTF-8

# Countries Controller nested under /admin
class Admin::CountriesController < AjaxController

  self.nesting = :admin

  self.search_columns = :name, :code

  self.default_sort = 'countries.name'

  self.permitted_attrs = [:name, :code] if respond_to?(:permitted_attrs)

  def show
    super do |format|
      format.html { redirect_to index_url, flash.to_hash }
    end
  end

end
