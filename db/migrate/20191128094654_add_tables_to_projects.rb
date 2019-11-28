class AddTablesToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :tables, :text, array: true, default: []
  end
end
