class CompetenciesController < ApplicationController
  SORT_MAP = {
    0 => "id",
    1 => "name"   
  }
  # GET /competencies
  # GET /competencies.json
  def index
    @competencies = Competency.all
    @levels = Level.all
    @slots = Slot.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @competencies }
      format.json { render json: @levels }
      format.json { render json: @slots }
    end
  end

  # GET /competencies/1
  # GET /competencies/1.json
  def show
    @competency = Competency.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @competency }
    end
  end

  # GET /competencies/new
  # GET /competencies/new.json
  def new
    @competency = Competency.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @competency }
    end
  end

  # GET /competencies/1/edit
  def edit
    @competency = Competency.find(params[:id])
  end

  # POST /competencies
  # POST /competencies.json
  def create
    @competency = Competency.new(name: params[:data])

    respond_to do |format|
      if @competency.save
        cds_template_id = params[:cds_template_id]
        @cds_template_competency =  CdsTemplatesCompetency.new(cds_template_id: cds_template_id, competency_id: Competency.last.id)
        if @cds_template_competency.save
          format.html { redirect_to @competency, notice: 'Competency was successfully created.' }
          format.json { render json: @competency, status: :created, location: @competency }
        else
          Competency.last.destroy
        end
      else
        format.json { render json: @competency.errors, status: :unprocessable_entity }
      end
    end

    # @competency = params[:data]
    # p @value, "------------------------------"
    # respond_to do |format|
    #   format.json{render :json => @value.to_json}
    # end


  end

  # PUT /competencies/1
  # PUT /competencies/1.json
  def update
    id = params[:competency_id]
    name = params[:data]
    @competency = Competency.find(id)
    respond_to do |format|
      if @competency.update_attributes(name: name)
        format.json{render :json => @competency.to_json}
      else
        format.html { render action: "edit" }
        format.json { render json: @competency.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /competencies/1
  # DELETE /competencies/1.json
  def destroy
    @competency = Competency.find(params[:data])
    @competency.destroy
    @list_relation = CdsTemplatesCompetency.where(competency_id: @competency.id).destroy_all

    @competencies = Competency.all

    respond_to do |format|
      format.json { render :json => @competency }
    end
  end

  def show_list_levels
    competency_id = params[:data]
    @competency = Competency.find(competency_id)
    
    render :layout => false
  end

  def get_all_competencies
    if request.xhr?
      cds_template_id = params[:cds_template_id]
      per_page = params[:iDisplayLength] ||  Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_MAP[params[:iSortCol_0].to_i]
      @competencies = Competency.get_competencies(cds_template_id, page, per_page, sort_field + " " + params[:sSortDir_0])
      render :json => @competencies
      return
    end
  end

  def get_competencies_in_cds
    if request.xhr?
      cds_template_id = params[:cds_template_id]
      per_page = params[:iDisplayLength] ||  Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_MAP[params[:iSortCol_0].to_i]
      @competencies = Competency.get_competencies_belong_to_cds(cds_template_id, page, per_page, sort_field + " " + params[:sSortDir_0])
      render :json => @competencies
      return
    end
  end

  def add_remove_competency_to_cds
    list_competencies = params[:data]
    cds_template_id = params[:cds_template_id]
    token = params[:authenticity_token]
    action = params[:action_type]

    if action == "add"
      list = Competency.handle_list_competencies_to_add_or_remove(list_competencies)
      list.each do |l|
        @cds_templates_competencies =  CdsTemplatesCompetency.new(cds_template_id: cds_template_id, competency_id: l.to_i)
        if !@cds_templates_competencies.save
          respond_to do |format|
            format.json { render :json => @cds_templates_competencies.errors }
          end
        end
      end
      respond_to do |format|
        format.json { render :json => "Successfully".to_json }
      end    
    else
      list = Competency.handle_list_competencies_to_add_or_remove(list_competencies)
      list.each do |l|
        @cds_templates_competencies = CdsTemplatesCompetency.where(cds_template_id: cds_template_id, competency_id: l.to_i)
        if !@cds_templates_competencies.destroy_all
          respond_to do |format|
            format.json { render :json => @cds_templates_competencies.errors }
          end
        end
      end
      respond_to do |format|
        format.json { render :json => "Successfully".to_json }
      end    
    end

  end

end
