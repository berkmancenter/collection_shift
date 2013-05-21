class ResultsController < ApplicationController
  def show
      @result = Calculation.find(params[:calculation_id]).result
  end

  def person_hours
  end

  def linear_feet
  end
end
