class CdsStructuresController < ApplicationController
  # GET /cds_structures
  # GET /cds_structures.json
  def index
    @cds_structures = CdsStructure.all
    @max_level = CdsStructure.maximum(:level)
    @levels = {}
    
    @levels[:level_1] = CdsStructure.where(level: 1)
    @levels[:level_1].each do |level_1|
      level_1[:level_2] = CdsStructure.where(parent_id: level_1.id)

      level_1[:level_2].each do |level_2|
        level_2[:level_3] = CdsStructure.where(parent_id: level_2.id)
      
        level_2[:level_3].each do |level_3|
          level_3[:level_4] = CdsStructure.where(parent_id: level_3.id)

          level_3[:level_4].each do |level_4|
            level_4[:level_5] = CdsStructure.where(parent_id: level_4.id)
          
            level_4[:level_5].each do |level_5|
              level_5[:level_6] = CdsStructure.where(parent_id: level_5.id)
            end
          end
        end
      end
    end

    # @levels[:level_1] = CdsStructure.where(level: 1) 
    # for i in 1..@max_level
    #   @levels[:"level_#{i}"].each do |l|
    #     l[:"level_#{i+1}"] = CdsStructure.where(parent_id: l.id)
    #   end
    # end














    p "==============================================="
    p @levels[:level_1][0][:level_2][0][:level_3][0][:level_4]




  
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cds_structures }
      format.json { render json: @levels }
    end
  end

  # GET /cds_structures/1
  # GET /cds_structures/1.json
  def show
    @cds_structure = CdsStructure.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cds_structure }
    end
  end

  # GET /cds_structures/new
  # GET /cds_structures/new.json
  def new
    @cds_structure = CdsStructure.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cds_structure }
    end
  end

  # GET /cds_structures/1/edit
  def edit
    @cds_structure = CdsStructure.find(params[:id])
  end

  # POST /cds_structures
  # POST /cds_structures.json
  def create
    @cds_structure = CdsStructure.new(params[:cds_structure])

    respond_to do |format|
      if @cds_structure.save
        format.html { redirect_to @cds_structure, notice: 'Cds structure was successfully created.' }
        format.json { render json: @cds_structure, status: :created, location: @cds_structure }
      else
        format.html { render action: "new" }
        format.json { render json: @cds_structure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cds_structures/1
  # PUT /cds_structures/1.json
  def update
    @cds_structure = CdsStructure.find(params[:id])

    respond_to do |format|
      if @cds_structure.update_attributes(params[:cds_structure])
        format.html { redirect_to @cds_structure, notice: 'Cds structure was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cds_structure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cds_structures/1
  # DELETE /cds_structures/1.json
  def destroy
    @cds_structure = CdsStructure.find(params[:id])
    @cds_structure.destroy

    respond_to do |format|
      format.html { redirect_to cds_structures_url }
      format.json { head :no_content }
    end
  end
end
