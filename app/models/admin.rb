class Admin < ApplicationRecord
  before_save { self.email.downcase! }
  validates :email, presence: true, length: { maximum: 255 },
              format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
              uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }
  has_secure_password
end
