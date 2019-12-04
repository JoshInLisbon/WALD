class RenameToAppFilesToCommands < ActiveRecord::Migration[5.2]
  def change
    rename_table :app_files, :commands
  end
end


