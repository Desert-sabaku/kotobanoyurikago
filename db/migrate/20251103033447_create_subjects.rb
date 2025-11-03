class CreateSubjects < ActiveRecord::Migration[8.1]
  def change
    create_table :subjects do |t|
      t.string :title, null: false
      t.text :description
      t.text :wiki_body
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
