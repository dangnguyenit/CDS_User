class ScoringScalesController < ApplicationController
    SORT_MAP = {
    0 => "id",
    1 => "id",
    2 => "name",
    3 => "score"   
  }
  # GET /scoring_scales
  # GET /scoring_scales.json
  def index
    @scoring_scales = ScoringScale.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @scoring_scales }
    end
  end

  # GET /scoring_scales/1
  # GET /scoring_scales/1.json
  def show
    @scoring_scale = ScoringScale.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @scoring_scale }
    end
  end

  # GET /scoring_scales/new
  # GET /scoring_scales/new.json
  def new
    @scoring_scale = ScoringScale.new
    @scoring = Scoring.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @scoring_scale }
    end
  end

  # GET /scoring_scales/1/edit
  def edit
    @scoring_scale = ScoringScale.find(params[:id])
  end

  # POST /scoring_scales
  # POST /scoring_scales.json
  def create
    @scoring_scales = params[:scoring_scale]
    count = params[:scoring_scale][:score].values.count 

    @scoring_scale = ScoringScale.new(name: @scoring_scales[:name], description: @scoring_scales[:description])
    
    for i in 0...count
      score = params[:scoring_scale][:score].values[i]
      des = params[:scoring_scale][:score_description].values[i]
      @scoring =  Scoring.new(score: score, description: des)
      unless @scoring.valid? || @scoring_scale.valid?
        # ScoringScale.last.destroy
        render :new and return
      end
    end


    unless @scoring_scale.save
      render :new and return
    else
      scoring_scale_id = ScoringScale.last.id
      type = params[:scoring_scale][:type]
      for i in 0...count
        score = params[:scoring_scale][:score].values[i]
        des = params[:scoring_scale][:score_description].values[i]
        @scoring =  Scoring.new(score: score, description: des, scoring_scale_id: scoring_scale_id, score_type: type)
        unless @scoring.save
          # ScoringScale.last.destroy
          render :new and return
        end
      end
      redirect_to scoring_scales_path
    end
  end

  # PUT /scoring_scales/1
  # PUT /scoring_scales/1.json
  def update
    @scoring_scale = ScoringScale.find(params[:id])

    respond_to do |format|
      if @scoring_scale.update_attributes(params[:scoring_scale])
        format.html { redirect_to @scoring_scale, notice: 'Scoring scale was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @scoring_scale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scoring_scales/1
  # DELETE /scoring_scales/1.json
  def destroy
    @scoring_scale = ScoringScale.find(params[:id])
    @scoring_scale.destroy

    respond_to do |format|
      format.html { redirect_to scoring_scales_url }
      format.json { head :no_content }
    end
  end

  def datatable_scoring_scales
    if request.xhr?
      # cds_template_id = params[:cds_template_id]
      per_page = params[:iDisplayLength] ||  Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_MAP[params[:iSortCol_0].to_i]
      @scoring_scales = ScoringScale.get_all_scoring_scales(page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0])
      render :json => @scoring_scales
      return
    end
  end

  def delete_selected
    list = params[:list_scoring_scales]
    unless list
      redirect_to action: "index"
    else
      list[:scoring_scale_id].each do |i|
        scoring_scale = ScoringScale.find(i)
        scoring_scale.destroy
      end
      redirect_to action: "index"
    end
  end

end
