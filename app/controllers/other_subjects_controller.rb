class OtherSubjectsController < ApplicationController
  # GET /other_subjects
  # GET /other_subjects.json
  def index
    @other_subjects = OtherSubject.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @other_subjects }
    end
  end

  # GET /other_subjects/1
  # GET /other_subjects/1.json
  def show
    @other_subject = OtherSubject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @other_subject }
    end
  end

  # GET /other_subjects/new
  # GET /other_subjects/new.json
  def new
    @other_subject = OtherSubject.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @other_subject }
    end
  end

  # GET /other_subjects/1/edit
  def edit
    @other_subject = OtherSubject.find(params[:id])
  end

  # POST /other_subjects
  # POST /other_subjects.json
  def create
    @other_subject = OtherSubject.new(params[:other_subject])

    respond_to do |format|
      if @other_subject.save
        format.html { redirect_to @other_subject, notice: 'Other subject was successfully created.' }
        format.json { render json: @other_subject, status: :created, location: @other_subject }
      else
        format.html { render action: "new" }
        format.json { render json: @other_subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /other_subjects/1
  # PUT /other_subjects/1.json
  def update
    @other_subject = OtherSubject.find(params[:id])

    respond_to do |format|
      if @other_subject.update_attributes(params[:other_subject])
        format.html { redirect_to @other_subject, notice: 'Other subject was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @other_subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /other_subjects/1
  # DELETE /other_subjects/1.json
  def destroy
    @other_subject = OtherSubject.find(params[:id])
    @other_subject.destroy

    respond_to do |format|
      format.html { redirect_to other_subjects_url }
      format.json { head :no_content }
    end
  end
end
