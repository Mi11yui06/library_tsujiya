class Stock < ApplicationRecord
  validates :arrival_date, presence: true
  belongs_to :catalog
end
