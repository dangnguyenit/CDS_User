class LevelsController < ApplicationController
  # GET /levels
  # GET /levels.json
  def index
    @levels = Level.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @levels }
    end
  end

  # GET /levels/1
  # GET /levels/1.json
  def show
    @level = Level.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @level }
    end
  end

  # GET /levels/new
  # GET /levels/new.json
  def new
    @level = Level.new
    @competency = Competency.find params[:competency]
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @level }
      format.json { render json: @competency }
    end
  end

  # GET /levels/1/edit
  def edit
    @level = Level.find(params[:id])
    @competency = @level.competency
  end

  # POST /levels
  # POST /levels.json
  def create
    level_name = params[:level_name]
    competency_id = params[:competency_id]
    @level = Level.new(name: level_name, competency_id: competency_id)

    respond_to do |format|
      if @level.save
        format.html { redirect_to @level, notice: 'Level was successfully created.' }
        format.json { render json: @level, status: :created, location: @level }
      else
        format.html { render action: "new" }
        format.json { render json: @level.errors, status: :unprocessable_entity }
      end
    end


    # @level = Level.new(params[:level])

    # respond_to do |format|
    #   if @level.save
    #     format.html { redirect_to @level, notice: 'Level was successfully created.' }
    #     format.json { render json: @level, status: :created, location: @level }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @level.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PUT /levels/1
  # PUT /levels/1.json
  def update
    id = params[:level_id]
    name = params[:data]
    @level = Level.find(id)
    respond_to do |format|
      if @level.update_attributes(name: name)  
        format.json { render :json => @level.to_json }
      else
        format.html { render action: "edit" }
        format.json { render json: @level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /levels/1
  # DELETE /levels/1.json
  def destroy
    @level = Level.find(params[:data])
    @slots_of_level = @level.slots.length
    @level.destroy

    respond_to do |format|
      format.json { render :json => @slots_of_level }
    end
  end

  def check_level_contain_slots
    level = Level.find(params[:data])
    @count = level.slots.length
    
    respond_to do |format|
      format.json { render :json => @count }
    end
  end
  
end
