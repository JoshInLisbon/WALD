class Project < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :xml_schema, presence: true
end
