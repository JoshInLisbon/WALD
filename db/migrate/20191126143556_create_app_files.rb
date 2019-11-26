class CreateAppFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :app_files do |t|
      t.string :name
      t.text :content
      t.string :path
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
