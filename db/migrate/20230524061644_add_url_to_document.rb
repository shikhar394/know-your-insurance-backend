class AddUrlToDocument < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :url, :text
    add_column :documents, :original_file_path, :text
  end
end
