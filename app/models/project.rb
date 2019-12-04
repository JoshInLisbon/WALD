class Project < ApplicationRecord
  belongs_to :user
  has_many :commands, dependent: :destroy

  validates :name, presence: true
  validates :xml_schema, presence: true
end
