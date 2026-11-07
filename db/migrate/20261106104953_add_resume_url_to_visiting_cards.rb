class AddResumeUrlToVisitingCards < ActiveRecord::Migration[8.1]
  def change
    add_column :visiting_cards, :resume_url, :string
  end
end
