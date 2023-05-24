class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.string :question, null: false
      t.text :context
      t.text :answer
      t.integer :ask_count, default: 1
      t.text :audio_src_url

      t.timestamps
    end
  end
end
