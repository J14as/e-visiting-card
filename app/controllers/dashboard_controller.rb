class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @cards = current_user.visiting_cards.order(created_at: :desc)
    @total_views = @cards.sum(:views_count)
    @active_cards_count = @cards.count
  end
end

