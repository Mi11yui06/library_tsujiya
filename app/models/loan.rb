class Loan < ApplicationRecord
  validates :loan_date, presence: true
  validate :validate_loan_conditions, :on => :confirm #=>は1対1
  validate :validate_loan_conditions, :on => :create
  belongs_to :member, optional: true
  belongs_to :stock, optional: true

  has_one :catalog, through: :stock

  before_validation :set_due_date


  # 返却期日の設定
  def set_due_date
    if self.loan_date.present? && self.stock.present?
      if self.stock.catalog.publish_date >= 3.months.ago.to_date
        self.due_date = self.loan_date + 10.days
      else
        self.due_date = self.loan_date + 15.days
      end
    end
  end

  # 延滞日数のロジック
  def overdue_days
    if return_date.present? || Date.today <= due_date
      return nil
    else
      (Date.today - due_date).to_i
    end
  end

  private

  def validate_loan_conditions
    validate_member
    validate_stock
    errors.add(:loan_date, "貸出年月日を入力してください") if loan_date.blank?
  end

  def validate_member
    if member_id.blank?
      errors.add(:base, "会員IDを入力してください")
    elsif member.nil?
      errors.add(:base, "指定された会員は存在しません")
    elsif member.remove_date.present?
      errors.add(:base, "指定された会員は退会しています")
    elsif member.loans.where(return_date: nil).where("due_date < ?", Date.today).exists?
      errors.add(:base, "指定された会員は延滞中です")
    elsif member.loans.where(return_date: nil).count >= MAX_CONCURRENT_LOANS #定数化する
      errors.add(:base, "指定された会員はすでに#{MAX_CONCURRENT_LOANS}冊貸出中です")
    end
  end

  def validate_stock
    if stock_id.blank?
      errors.add(:base, "資料IDを入力してください")
    elsif stock.nil?
      errors.add(:base, "指定された資料は存在しません")
    elsif stock.discarded?
      errors.add(:base, "指定された資料は廃棄されています")
    elsif Loan.exists?(stock_id: stock_id, return_date: nil)
      errors.add(:base, "指定された資料は貸出中です")
    end
  end
end
