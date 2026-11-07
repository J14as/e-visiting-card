class CreateVisitingCards < ActiveRecord::Migration[8.1]
  def change
    create_table :visiting_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.string :card_title, default: "My Digital Card"
      t.string :full_name, null: false
      t.string :designation
      t.string :company_or_tagline
      t.text :bio
      t.string :phone
      t.string :email
      t.string :website_url
      t.string :linkedin_url
      t.string :github_url
      t.string :instagram_url
      t.string :portfolio_url
      t.string :template_style, default: "modern_dark", null: false
      t.string :color_theme, default: "indigo", null: false
      t.string :slug, null: false
      t.integer :views_count, default: 0, null: false

      t.timestamps
    end

    add_index :visiting_cards, :slug, unique: true
  end
end
