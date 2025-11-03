class AddUniqueIndexToSubjects < ActiveRecord::Migration[8.1]
  def change
    unless index_exists?(:subjects, :title, unique: true)
      add_index :subjects, :title, unique: true, name: "index_subjects_on_title_unique"
    end
  end
end
