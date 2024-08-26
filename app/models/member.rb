class Member < ApplicationRecord
  before_save { self.email.downcase! }
  before_save :format_post_code
  validates :name, :address, :tel, :birth_date, :join_date, presence: true
  validates :email, presence: true, length: { maximum: 255 },
              format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
              uniqueness: { case_sensitive: false }
  validates :post_code, presence: true, format: { with: /\A\d{7}\z/ }
  has_many :loans

  # 会員が延滞しているかどうか
  def overdue?
    loans.where("return_date IS NULL AND due_date < ?", Date.today).exists?
  end

  # 会員が今貸出できる冊数
  def available_loans_count
    return 0 if overdue?
    [MAX_CONCURRENT_LOANS - loans.where("return_date IS NULL").count, 0].max
  end
  
  private
  def format_post_code
    if post_code.present?
      # 数字だけを抽出
      cleaned_post_code = post_code.gsub(/\D/, '')
      # ハイフンありの形式に変換
      formatted_post_code = cleaned_post_code.insert(3, '-') if cleaned_post_code.length == 7
      self.post_code = "〒" + formatted_post_code
    end
  end
end
