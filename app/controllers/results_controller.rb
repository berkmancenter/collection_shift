class ResultsController < ApplicationController
  def show
      @calculation = Calculation.find(params[:calculation_id])
      @result = @calculation.result
  end

  def recalculate
      calculation = Calculation.find(params[:calculation_id])
      @calculation = calculation.dup
      @calculation.save!
      Calculator.perform_async(@calculation.id)
      flash[:notice] = "Depending on the size of the call number range, this may take a while."
      if @calculation.email_to_notify.present?
          flash[:notice] += " We'll let you know when it's finished."
      else
          flash[:notice] += " Refresh this page to check for completion."
      end
      redirect_to root_path
  end

  def person_hours
  end

  def linear_feet
  end
end
