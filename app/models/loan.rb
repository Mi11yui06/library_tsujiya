class Loan < ApplicationRecord
  validates :loan_date, :due_date, presence: true
  belongs_to :member
  belongs_to :stock

  before_validation :set_due_date


  def set_due_date
    logger.debug("Loan Date before calculation: #{self.loan_date}")
    if self.loan_date.present? && self.stock.present?
      if self.stock.catalog.publish_date >= 3.month.ago.to_date
        self.due_date = self.loan_date + 10.days
        logger.debug("Due Date set to (新刊本): #{self.due_date}")
      else
        self.due_date = self.loan_date + 15.days
        logger.debug("Due Date set to (旧刊本): #{self.due_date}")
      end
    end
    logger.debug("Final Due Date: #{self.due_date}")
    self.due_date
  end

  def overdue_days
    if return_date.present? || Date.today <= due_date
      return nil
    else
      (Date.today - due_date).to_i
    end
  end

end

