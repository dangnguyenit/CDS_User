class TitlesController < ApplicationController
  SORT_MAP = {
    0 => "id",
    1 => "id",
    2 => "id",
    3 => "name",
    4 => "short_name"
    
  }

  # GET /titles
  # GET /titles.json
  def index
    if request.xhr?
      per_page = params[:iDisplayLength] ||  Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_MAP[params[:iSortCol_0].to_i]
      @titles = Title.get_all_titles(page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0])
      render :json => @titles
      return
    end
  end

  # GET /titles/1
  # GET /titles/1.json
  def show
    @title = Title.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @title }
    end
  end

  # GET /titles/new
  # GET /titles/new.json
  def new
    @cds_template_id = params[:cds_template_id]
    @title = Title.new
    @competencies = Competency.order("id")
    @minimum_reqs = MinimumRequirement.order("id")

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @title }
    end
  end

  # GET /titles/1/edit
  def edit
    @cds_template_id = params[:cds_template_id]
    @title = Title.find(params[:id])
    @title_competencies = @title.title_competencies
    @title_minimums = @title.title_minimums

    @competencies = Competency.all
    @minimum_reqs = MinimumRequirement.all
  end

  # POST /titles
  # POST /titles.json
  def create
    cds_template_id = params[:title][:cds_template_id]
    title_name = params[:title][:name]
    title_short_name = params[:title][:short_name]
    @title = {}
    @title = Title.new(name: "#{title_name}", short_name: "#{title_short_name}")

    
    if !@title.save
      @competencies = Competency.all
      @minimum_reqs = MinimumRequirement.all
      render :new and return
    end
    id = Title.last.id

    CdsTemplatesTitle.create(cds_template_id: cds_template_id, title_id: id)    

    competencies = Competency.all
    competencies.each do |c|

      name = c.name.downcase.gsub(' ','_')
      if params[:title][:"#{name}"]
        values = params[:title][:"#{name}"]
        level_ranking = values.values[0]

        if values.count==2
          low = values[:low_level_value]
          hight = values[:hight_level_value]
          level_ranking = "#{low}-#{hight}"
        end

        @title_competency = TitleCompetency.new(level_ranking: "#{level_ranking}", title_id: "#{id}", competency_id: "#{c.id}")
        if !@title_competency.save
          render :new and return
        end
      else
        next
      end
    end

    minimum_reqs = MinimumRequirement.all
    minimum_reqs.each do |m|
      name = m.name.downcase.gsub(' ','_')
      if params[:title][:"#{name}"]
        scoring_id = params[:title][:"#{name}"].values[0]

        @title_minimum = TitleMinimum.new(title_id: "#{id}", scoring_id: "#{scoring_id}")
        if !@title_minimum.save
          render :new and return
        end
      else
        next
      end
    end

    redirect_to cds_template_path(cds_template_id) if @title.valid? && @title_competency.valid? && @title_minimum.valid?
  end

  # PUT /titles/1
  # PUT /titles/1.json
  def update
    cds_template_id = params[:title][:cds_template_id]
    p cds_template_id, "======================"

    @title = Title.find(params[:id])
    @title.update_attributes(params[:title].slice(:name, :short_name))

    competencies = @title.title_competencies
    competencies.each do |c|
      name = c.competency.name.downcase.gsub(' ','_')
      if params[:title][:"#{name}"]
        values = params[:title][:"#{name}"]
        level_ranking = values.values[0]
        if values.count==2
          low = values[:low_level_value]
          hight = values[:hight_level_value]
          level_ranking = "#{low}-#{hight}"
        end  
        @title_competency = c.update_attributes(level_ranking: "#{level_ranking}")
      else
        next
      end
    end

    minimum_reqs = @title.title_minimums
    minimum_reqs.each do |m|
      name = m.scoring.scoring_scale.minimum_requirements[0].name.downcase.gsub(' ','_')
      if params[:title][:"#{name}"]
        scoring_id = params[:title][:"#{name}"].values[0]
        @title_minimum = m.update_attributes(scoring_id: "#{scoring_id}")
      else
        next
      end
    end

    # redirect_to @title
    redirect_to cds_template_path(cds_template_id)
  end

  # DELETE /titles/1
  # DELETE /titles/1.json
  def destroy
    @title = Title.find(params[:id])
    @title.destroy

    respond_to do |format|
      format.html { redirect_to titles_url }
      format.json { head :no_content }
    end
  end

  def datatable_titles
    if request.xhr?
      cds_template_id = params[:cds_template_id]
      per_page = params[:iDisplayLength] ||  Settings.per_page
      page = params[:iDisplayStart] ? ((params[:iDisplayStart].to_i/per_page.to_i) + 1) : 1
      params[:iSortCol_0] = 1 if params[:iSortCol_0].blank?
      sort_field = SORT_MAP[params[:iSortCol_0].to_i]
      @titles = Title.get_titles_belong_to_template(cds_template_id, page, per_page, params[:sSearch], sort_field + " " + params[:sSortDir_0])
      render :json => @titles
      return
    end
  end

  def delete_selected
    list = params[:list_titles]
    unless list
      redirect_to action: "index"
    else
      list[:title_id].each do |i|
        title = Title.find(i)
        title.destroy
      end
      redirect_to action: "index"
    end
  end



end
