class Category < ApplicationRecord
  validates :code, :name, presence: true
  has_many :catalogs
end
