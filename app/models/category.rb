class Category < ApplicationRecord
  validates :code, :name, presence: true
  has_many :catalogs
  def code_with_name
    "#{code}: #{name}"
  end
end
