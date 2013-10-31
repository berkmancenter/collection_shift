class Calculator
    include Sidekiq::Worker
    def perform(calculation_id)
        calc = Calculation.where(id: calculation_id)
        if calc.empty?
            return
        else
            calc = calc.first
        end
        calc.calculate
        calc.save!
        if calc.email_to_notify.present?
            CalculationMailer.complete_email(calc).deliver
        end
    end
end
