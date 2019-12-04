class Command < ApplicationRecord
  belongs_to :project

  validates :cmd_string, presence: true
  validates :project_id, presence: true
end
