class PublicCardsController < ApplicationController
  # Public profile access does not require authentication
  skip_before_action :verify_authenticity_token, only: %i[vcard qr pdf resume]
  before_action :set_card

  layout "public_card"

  def show
    # Force mobile browsers (Safari/Chrome) to never serve stale cache when re-scanning QR codes
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"

    # Throttle view counter to avoid spamming on refreshes
    session_key = "viewed_card_#{@card.id}"
    unless session[session_key]
      @card.increment!(:views_count)
      session[session_key] = true
    end

    @public_url = card_public_url(@card)
    @qr_svg = @card.qr_code_svg(@public_url, module_size: 6)
  end

  def vcard
    vcf_content = @card.to_vcf(card_public_url(@card))
    send_data vcf_content,
              filename: "#{@card.slug}.vcf",
              type: "text/vcard; charset=utf-8",
              disposition: "attachment"
  end

  def pdf
    public_url = card_public_url(@card)
    layout = params[:layout] == "sheet" ? :sheet : :card
    pdf_data = VisitingCardPdfGenerator.render(@card, public_url, layout: layout)

    suffix = layout == :sheet ? "print-sheet" : "visiting-card"
    send_data pdf_data,
              filename: "#{@card.slug}-#{suffix}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end

  def resume
    if @card.resume.attached?
      send_data @card.resume.download,
                filename: @card.resume.filename.to_s,
                content_type: @card.resume.content_type,
                disposition: "attachment"
    elsif @card.resume_url.present?
      redirect_to @card.resume_url, allow_other_host: true
    else
      redirect_to public_card_path(@card.slug), alert: "No resume attached."
    end
  end

  def qr
    public_url = card_public_url(@card)
    if params[:fmt] == "png"
      send_data @card.qr_code_png(public_url, size: 600),
                type: "image/png",
                disposition: "inline"
    else
      send_data @card.qr_code_svg(public_url, module_size: 8),
                type: "image/svg+xml",
                disposition: "inline"
    end
  end

  private

  def set_card
    @card = VisitingCard.friendly.find(params[:slug])
  rescue ActiveRecord::RecordNotFound
    render "errors/not_found", status: :not_found, layout: "application"
  end
end
