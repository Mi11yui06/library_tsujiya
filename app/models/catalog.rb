class Catalog < ApplicationRecord
  validates :title, :author, :publisher, :publish_date, presence: true
  validates :isbn, presence: true, uniqueness: true
  belongs_to :category
  has_many :stocks
end
