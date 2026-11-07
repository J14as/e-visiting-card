class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :capture_app_host

  helper_method :card_public_url, :active_app_host

  # Builds the public profile URL for QR codes and sharing.
  # Automatically adapts to ngrok, tunnels, or APP_HOST for mobile phone testing.
  def card_public_url(card)
    "#{active_app_host}/c/#{card.slug}"
  end

  def active_app_host
    ENV["APP_HOST"].presence || session[:app_host].presence || request.base_url
  end

  private

  def capture_app_host
    if params[:clear_app_host].present?
      session.delete(:app_host)
    elsif params[:app_host].present?
      session[:app_host] = params[:app_host].to_s.strip.chomp("/")
    elsif request.host.include?("ngrok") || request.host.include?("loca.lt")
      session[:app_host] = request.base_url
    end
  end

  # Changes to Devise redirects
  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
