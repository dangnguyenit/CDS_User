class SlotsController < ApplicationController
  # GET /slots
  # GET /slots.json
  def index
    @slots = Slot.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @slots }
    end
  end

  # GET /slots/1
  # GET /slots/1.json
  def show
    @slot = Slot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @slot }
    end
  end

  # GET /slots/new
  # GET /slots/new.json
  def new
    @slot = Slot.new
    @level = Level.find params[:level]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @slot }
      format.json { render json: @level }
    end
  end

  # GET /slots/1/edit
  def edit
    @slot = Slot.find(params[:id])
    @level = @slot.level
  end

  # POST /slots
  # POST /slots.json
  def create
    slot_name = params[:slot_name]
    description = params[:description]
    level_id = params[:level_id]
    @slot = Slot.new(name: slot_name, description: description, level_id: level_id)


    respond_to do |format|
      if @slot.save
        format.json { render json: @slot, status: :created, location: @slot }
      else
        p @slot.errors.to_json, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        format.json { render json: @slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /slots/1
  # PUT /slots/1.json
  def update
    id = params[:slot_id]
    name = params[:data]
    description = params[:description]

    @slot = Slot.find(id)

    respond_to do |format|
      if @slot.update_attributes(name: name, description: description)
        format.json { render :json => @slot.to_json }
      else
        format.html { render action: "edit" }
        format.json { render json: @slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /slots/1
  # DELETE /slots/1.json
  def destroy
    @slot = Slot.find(params[:data])
    @slot.destroy

    @competencies = Competency.all

    respond_to do |format|
      format.json { render :json => @competencies }
    end
  end

  def get_slots_belong_to_level
    level_id = params[:data]
    @slots = Slot.where(level_id: level_id)

    render :layout => false
  end

end
