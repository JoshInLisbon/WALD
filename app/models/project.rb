class Project < ApplicationRecord
  belongs_to :user
  has_many :appFiles

  validates :name, presence: true
  validates :xml_schema, presence: true
end
