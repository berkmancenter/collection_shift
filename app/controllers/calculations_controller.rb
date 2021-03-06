class CalculationsController < ApplicationController
  # GET /calculations
  # GET /calculations.json
  def index
    @calculations = Calculation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @calculations }
    end
  end

  # GET /calculations/1
  # GET /calculations/1.json
  def show
    @calculation = Calculation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @calculation }
    end
  end

  # GET /calculations/new
  # GET /calculations/new.json
  def new
    @calculation = Calculation.new
    @calculation.result = @calculation.build_result

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @calculation }
    end
  end

  # GET /calculations/1/edit
  def edit
    @calculation = Calculation.find(params[:id])
  end

  # POST /calculations
  # POST /calculations.json
  def create
    @calculation = Calculation.new(params[:calculation])

    respond_to do |format|
      if @calculation.save
        Calculator.perform_async(@calculation.id) unless @calculation.result.estimated_feet
        format.html do
            if @calculation.result.estimated_feet
                redirect_to calculation_result_path(@calculation, @calculation.result)
            else
                flash[:notice] = "Depending on the size of the call number range, this may take a while."
                if @calculation.email_to_notify.present?
                    flash[:notice] += " We'll let you know when it's finished."
                else
                    flash[:notice] += " Refresh this page to check for completion."
                end
                redirect_to root_path
            end
        end
        format.json { render json: @calculation.result, status: :created, location: @calculation.result }
      else
        format.html { render action: "new" }
        format.json { render json: @calculation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /calculations/1
  # PUT /calculations/1.json
  def update
    @calculation = Calculation.find(params[:id])

    respond_to do |format|
      if @calculation.update_attributes(params[:calculation])
        format.html { redirect_to @calculation, notice: 'Calculation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @calculation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /calculations/1
  # DELETE /calculations/1.json
  def destroy
    @calculation = Calculation.find(params[:id])
    @calculation.destroy

    respond_to do |format|
      format.html do
          redirect_to calculations_url 
      end
      format.json { head :no_content }
    end
  end
end
