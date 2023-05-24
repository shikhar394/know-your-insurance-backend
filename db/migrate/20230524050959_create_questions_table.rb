class CreateQuestionsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :questions_tables do |t|
      t.string :question, limit: 256, null: false
      t.text :context, null: true
      t.text :answer, limit: 1000, null: true
      t.integer :ask_count, default: 1
      t.string :audio_src_url, null: true
      t.timestamps
    end
  end
end
