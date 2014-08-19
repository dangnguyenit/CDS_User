class MinimumRequirementsController < ApplicationController
  SORT_MAP = {
    0 => "id",
    1 => "name",
    2 => "name"
  }
  # GET /minimum_requirements
  # GET /minimum_requirements.json
  def index
    @minimum_requirements = MinimumRequirement.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @minimum_requirements }
    end
  end

  # GET /minimum_requirements/1
  # GET /minimum_requirements/1.json
  def show
    @minimum_requirement = MinimumRequirement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @minimum_requirement }
    end
  end

  # GET /minimum_requirements/new
  # GET /minimum_requirements/new.json
  def new
    @minimum_requirement = MinimumRequirement.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @minimum_requirement }
    end
  end

  # GET /minimum_requirements/1/edit
  def edit
    @minimum_requirement = MinimumRequirement.find(params[:id])
  end

  # POST /minimum_requirements
  # POST /minimum_requirements.json
  def create
    @minimum_requirement = MinimumRequirement.new(params[:minimum_requirement])

    respond_to do |format|
      if @minimum_requirement.save
        format.html { redirect_to @minimum_requirement, notice: 'Minimum requirement was successfully created.' }
        format.json { render json: @minimum_requirement, status: :created, location: @minimum_requirement }
      else
        format.html { render action: "new" }
        format.json { render json: @minimum_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /minimum_requirements/1
  # PUT /minimum_requirements/1.json
  def update
    @minimum_requirement = MinimumRequirement.find(params[:id])

    respond_to do |format|
      if @minimum_requirement.update_attributes(params[:minimum_requirement])
        format.html { redirect_to @minimum_requirement, notice: 'Minimum requirement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @minimum_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /minimum_requirements/1
  # DELETE /minimum_requirements/1.json
  def destroy
    @minimum_requirement = MinimumRequirement.find(params[:id])
    @minimum_requirement.destroy

    respond_to do |format|
      format.html { redirect_to minimum_requirements_url }
      format.json { head :no_content }
    end
  end

  def datatable_minimum_requirements
    if request.xhr?
      per_page = params[:iDisplayLength] ||  Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_MAP[params[:iSortCol_0].to_i]
      @minimum_requirements = MinimumRequirement.get_all_minimum_requirements(page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0])
      render :json => @minimum_requirements
      return
    end
  end

  def delete_selected
    list = params[:list_minimum_requirements]
    unless list
      redirect_to action: "index"
    else
      list[:minimum_requirement_id].each do |i|
        minimum_requirement = MinimumRequirement.find(i)
        minimum_requirement.destroy
      end
      redirect_to action: "index"
    end
  end

end
