class ResultsController < ApplicationController
  def show
      @calculation = Calculation.find(params[:calculation_id])
      @result = @calculation.result
  end

  def person_hours
  end

  def linear_feet
  end
end
