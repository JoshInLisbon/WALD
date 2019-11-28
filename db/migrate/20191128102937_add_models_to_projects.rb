class AddModelsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :models, :text, array: true, default: []
  end
end
