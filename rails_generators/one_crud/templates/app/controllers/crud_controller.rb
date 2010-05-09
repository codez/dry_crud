class CrudController < ApplicationController
  # GET /cruds
  # GET /cruds.xml
  def index
    @cruds = Crud.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cruds }
    end
  end

  # GET /cruds/1
  # GET /cruds/1.xml
  def show
    @crud = Crud.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @crud }
    end
  end

  # GET /cruds/new
  # GET /cruds/new.xml
  def new
    @crud = Crud.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @crud }
    end
  end

  # GET /cruds/1/edit
  def edit
    @crud = Crud.find(params[:id])
  end

  # POST /cruds
  # POST /cruds.xml
  def create
    @crud = Crud.new(params[:crud])

    respond_to do |format|
      if @crud.save
        flash[:notice] = 'Crud was successfully created.'
        format.html { redirect_to(@crud) }
        format.xml  { render :xml => @crud, :status => :created, :location => @crud }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @crud.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cruds/1
  # PUT /cruds/1.xml
  def update
    @crud = Crud.find(params[:id])

    respond_to do |format|
      if @crud.update_attributes(params[:crud])
        flash[:notice] = 'Crud was successfully updated.'
        format.html { redirect_to(@crud) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @crud.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cruds/1
  # DELETE /cruds/1.xml
  def destroy
    @crud = Crud.find(params[:id])
    @crud.destroy

    respond_to do |format|
      format.html { redirect_to(cruds_url) }
      format.xml  { head :ok }
    end
  end
end
