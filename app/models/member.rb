class Member < ApplicationRecord
  before_save { self.email.downcase! }
  before_save :format_post_code
  validates :name, :address, :tel, :birth_date, :join_date, presence: true
  validates :email, presence: true, length: { maximum: 255 },
              format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
              uniqueness: { case_sensitive: false }
  validates :post_code, presence: true, format: { with: /\A\d{7}\z/ }
  has_many :loans

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
