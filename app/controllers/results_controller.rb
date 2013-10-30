class ResultsController < ApplicationController
  def show
      @calculation = Calculation.find(params[:calculation_id])
      @result = @calculation.result
  end

  def recalculate
      calculation = Calculation.find(params[:calculation_id])
      @calculation = calculation.dup
      @calculation.calculate
      @calculation.save!
      redirect_to calculation_result_path(@calculation.id, @calculation.result.id)
  end

  def person_hours
  end

  def linear_feet
  end
end
