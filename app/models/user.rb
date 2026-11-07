class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :visiting_cards, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  def display_name
    name.presence || email.split("@").first.titleize
  end
end
