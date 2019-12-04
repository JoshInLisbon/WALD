class RemoveNameToAppFiles < ActiveRecord::Migration[5.2]
  def change
    remove_column :app_files, :name
    remove_column :app_files, :path
    rename_column :app_files, :content, :cmd_string
  end
end
