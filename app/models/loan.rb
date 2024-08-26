class Loan < ApplicationRecord
  validates :loan_date, presence: true
  validate :validate_loan_conditions, :on => :confirm #=>は1対1
  validate :validate_loan_conditions, :on => :create
  belongs_to :member, optional: true
  belongs_to :stock, optional: true

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
    # 会員IDのバリデーション
    if member_id.blank?
      errors.add(:base, "会員IDを入力してください")
    elsif member.nil?
      errors.add(:base, "指定された会員は存在しません")
    elsif member.remove_date.present?
      errors.add(:base, "指定された会員は退会しています")
    elsif member_overdue?
      errors.add(:base, "指定された会員は延滞中です")
    elsif loan_limit_exceeded?
      errors.add(:base, '指定された会員はすでに5冊貸出中です')
    end
    
    # 資料IDのバリデーション
    if stock_id.blank?
    errors.add(:base, "資料IDを入力してください")
    else
      if stock.nil?
        errors.add(:base, "指定された資料は存在しません")
      elsif stock.discarded?
        errors.add(:base, "指定された資料は廃棄されています")
      elsif Loan.exists?(stock_id: stock_id, return_date: nil)
        errors.add(:base, "指定された資料は貸出中です")
      end
    end

    if loan_date.blank?
      errors.add(:loan_date, "貸出年月日を入力してください")
    end
  end

  # 返却日が記入されているか？
  # def return_date_present?
  #   !return_date.nil?
  # end

  # 延滞しているかどうか
  def member_overdue?
    member.loans.where(return_date: nil).where("due_date < ?", Date.today).exists?
  end

  # すでに5冊貸出中か
  def loan_limit_exceeded?
    member.loans.where(return_date: nil).count >= 5 #定数化する
  end
end

