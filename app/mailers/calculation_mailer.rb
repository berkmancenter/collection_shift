class CalculationMailer < ActionMailer::Base
  default from: "calculator@example.com"

  def complete_email(calculation)
    @calculation = calculation

    mail to: calculation.email_to_notify, subject: 'CollectionShift - Calculation Complete'
  end
end
