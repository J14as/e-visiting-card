class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, only: %i[edit update destroy duplicate download_pdf download_qr download_resume preview]

  def index
    redirect_to dashboard_path
  end

  def new
    @card = current_user.visiting_cards.build(
      card_title: "My Professional Card",
      template_style: "editorial",
      color_theme: "indigo",
      full_name: current_user.name.presence || "",
      email: current_user.email
    )
  end

  def create
    @card = current_user.visiting_cards.build(card_params)
    if @card.save
      redirect_to edit_card_path(@card), notice: "Card created! Start customizing below."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @public_url = card_public_url(@card)
  end

  def update
    if @card.update(card_params)
      respond_to do |format|
        format.html { redirect_to edit_card_path(@card), notice: "Visiting card saved successfully!" }
        format.turbo_stream
      end
    else
      @public_url = card_public_url(@card)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
    redirect_to dashboard_path, notice: "Visiting card was deleted successfully."
  end

  def duplicate
    new_card = @card.dup
    new_card.card_title = "#{@card.card_title} (Copy)"
    new_card.slug = nil
    new_card.views_count = 0

    if new_card.save
      redirect_to edit_card_path(new_card), notice: "Card duplicated! Customize this copy as you wish."
    else
      redirect_to dashboard_path, alert: "Unable to duplicate card: #{new_card.errors.full_messages.to_sentence}"
    end
  end

  def download_pdf
    public_url = card_public_url(@card)
    layout = params[:layout] == "sheet" ? :sheet : :card
    pdf_data = VisitingCardPdfGenerator.render(@card, public_url, layout: layout)

    suffix = layout == :sheet ? "print-sheet" : "visiting-card"
    send_data pdf_data,
              filename: "#{@card.slug}-#{suffix}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end

  def download_qr
    public_url = card_public_url(@card)
    format = params[:fmt] == "svg" ? :svg : :png

    if format == :svg
      send_data @card.qr_code_svg(public_url, module_size: 8),
                filename: "#{@card.slug}-qr.svg",
                type: "image/svg+xml",
                disposition: "attachment"
    else
      send_data @card.qr_code_png(public_url, size: 800),
                filename: "#{@card.slug}-qr.png",
                type: "image/png",
                disposition: "attachment"
    end
  end

  def download_resume
    if @card.resume.attached?
      redirect_to rails_blob_path(@card.resume, disposition: "attachment")
    elsif @card.resume_url.present?
      redirect_to @card.resume_url, allow_other_host: true
    else
      redirect_to edit_card_path(@card), alert: "No resume attached to this card."
    end
  end

  def preview
    render partial: "cards/preview_card", locals: { card: @card, public_url: public_card_url(@card.slug) }
  end

  private

  def set_card
    @card = current_user.visiting_cards.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "Card not found."
  end

  def card_params
    params.require(:visiting_card).permit(
      :card_title,
      :full_name,
      :designation,
      :company_or_tagline,
      :bio,
      :phone,
      :email,
      :website_url,
      :linkedin_url,
      :github_url,
      :instagram_url,
      :portfolio_url,
      :template_style,
      :color_theme,
      :slug,
      :avatar,
      :resume,
      :resume_url
    )
  end
end
