class CdsTemplatesController < ApplicationController
    SORT_MAP = {
    0 => "id",
    1 => "id",
    2 => "name",
    3 => "created_at",
    8 => "status"
  }
  # GET /cds_templates
  # GET /cds_templates.json
  def index
    if request.xhr?
      per_page = params[:iDisplayLength] ||  Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_MAP[params[:iSortCol_0].to_i]
      @cds_template = CdsTemplate.get_all_cds_template(page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0])
      render :json => @cds_template
      return
    end
  end

  # GET /cds_templates/1
  # GET /cds_templates/1.json
  def show
    @cds_template = CdsTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cds_template }
    end
  end

  # GET /cds_templates/new
  # GET /cds_templates/new.json
  def new
    @cds_template = CdsTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cds_template }
    end
  end

  # GET /cds_templates/1/edit
  def edit
    @cds_template = CdsTemplate.find(params[:id])
    @cds_template.start_date = @cds_template.start_date.strftime("%d-%m-%Y")
    @cds_template.end_date = @cds_template.end_date.strftime("%d-%m-%Y")
    @cds_template.start_assess_date = @cds_template.start_assess_date.strftime("%d-%m-%Y")
    @cds_template.end_assess_date = @cds_template.end_assess_date.strftime("%d-%m-%Y")
  end

  # POST /cds_templates
  # POST /cds_templates.json
  def create
    @cds_template = CdsTemplate.new(params[:cds_template])

    respond_to do |format|
      if @cds_template.save
        format.html { redirect_to @cds_template, notice: 'Cds template was successfully created.' }
        format.json { render json: @cds_template, status: :created, location: @cds_template }
      else
        format.html { render action: "new" }
        format.json { render json: @cds_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cds_templates/1
  # PUT /cds_templates/1.json
  def update
    @cds_template = CdsTemplate.find(params[:id])

    respond_to do |format|
      if @cds_template.update_attributes(params[:cds_template])
        format.html { redirect_to @cds_template, notice: 'Cds template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cds_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cds_templates/1
  # DELETE /cds_templates/1.json
  def destroy
    @cds_template = CdsTemplate.find(params[:id])
    @cds_template.destroy

    respond_to do |format|
      format.html { redirect_to cds_templates_url }
      format.json { head :no_content }
    end
  end

  def delete_selected
    list = params[:list_cds_template]
    unless list
      redirect_to action: "index"
    else
      list[:cds_template_id].each do |i|
        cds_template = CdsTemplate.find(i)
        cds_template.destroy
      end
      redirect_to action: "index"
    end
  end
end
