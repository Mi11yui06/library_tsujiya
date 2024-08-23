class Stock < ApplicationRecord
  validates :arrival_date, presence: true
  belongs_to :catalog
  has_many :loans

  # 最新の貸出が未返却かどうかを判定
  def currently_on_loan?
    loans.where(return_date: nil).exists?
  end

  # 廃棄済かどうか
  def discarded?
    !disposal_date.nil?
  end

  # 新刊かどうか
  def new_book?
    catalog.publish_date >= 3.months.ago.to_date
  end
end
