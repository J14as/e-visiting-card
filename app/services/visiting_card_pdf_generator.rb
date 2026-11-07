require "prawn"
require "prawn/measurement_extensions"

Prawn::Fonts::AFM.hide_m17n_warning = true

class VisitingCardPdfGenerator
  # Standard business card dimensions: 3.5 x 2.0 inches = 252 x 144 pt
  CARD_WIDTH = 252.0
  CARD_HEIGHT = 144.0

  def self.render(card, public_url, layout: :card)
    new(card, public_url, layout: layout).generate
  end

  def initialize(card, public_url, layout: :card)
    @card = card
    @public_url = public_url
    @style = card.template_style
    @layout = layout.to_sym
  end

  def generate
    if @layout == :sheet
      generate_print_sheet
    else
      generate_individual_card
    end
  end

  private

  # 1. Exact 3.5" x 2.0" Business Card (2 Pages: Front & Back)
  def generate_individual_card
    # NOTE: DO NOT pass page_layout: :landscape when page_size is [width, height] array!
    # Prawn automatically treats [252, 144] as landscape because width > height.
    pdf = Prawn::Document.new(
      page_size: [CARD_WIDTH, CARD_HEIGHT],
      margin: 0
    )

    theme_colors = fetch_theme_colors

    # PAGE 1: FRONT SIDE
    draw_card_face(pdf, 0, CARD_HEIGHT, theme_colors, :front)

    # PAGE 2: BACK SIDE
    pdf.start_new_page(size: [CARD_WIDTH, CARD_HEIGHT], margin: 0)
    draw_card_face(pdf, 0, CARD_HEIGHT, theme_colors, :back)

    pdf.render
  end

  # 2. A4 Printable Sheet with Cut / Crop Guidelines (Both sides centered)
  def generate_print_sheet
    # A4 standard size: 595.28 x 841.89 pt
    pdf = Prawn::Document.new(
      page_size: "A4",
      page_layout: :portrait,
      margin: 36
    )

    theme_colors = fetch_theme_colors

    # Sheet Header
    pdf.fill_color "0F172A"
    pdf.font("Helvetica", style: :bold, size: 16)
    pdf.text "CardForge — Print-Ready Digital Visiting Card", align: :center
    pdf.move_down 4

    pdf.fill_color "64748B"
    pdf.font("Helvetica", size: 9)
    pdf.text "Standard Business Card Size: 3.5\" × 2.0\" (88.9mm × 50.8mm) • Print at 100% scale (Do not scale/shrink)", align: :center
    pdf.move_down 24

    sheet_width = pdf.bounds.width
    card_x = (sheet_width - CARD_WIDTH) / 2.0

    # Section 1: FRONT SIDE
    pdf.fill_color "334155"
    pdf.font("Helvetica", style: :bold, size: 10)
    pdf.text "CARD FRONT", align: :center, character_spacing: 1
    pdf.move_down 8

    front_y = pdf.cursor
    # Draw cut guidelines around front
    draw_crop_marks(pdf, card_x, front_y, CARD_WIDTH, CARD_HEIGHT)
    # Draw Front Card
    draw_card_face(pdf, card_x, front_y, theme_colors, :front)

    pdf.move_cursor_to(front_y - CARD_HEIGHT - 32)

    # Section 2: BACK SIDE
    pdf.fill_color "334155"
    pdf.font("Helvetica", style: :bold, size: 10)
    pdf.text "CARD BACK (DYNAMIC QR CODE)", align: :center, character_spacing: 1
    pdf.move_down 8

    back_y = pdf.cursor
    # Draw cut guidelines around back
    draw_crop_marks(pdf, card_x, back_y, CARD_WIDTH, CARD_HEIGHT)
    # Draw Back Card
    draw_card_face(pdf, card_x, back_y, theme_colors, :back)

    pdf.move_cursor_to(back_y - CARD_HEIGHT - 24)

    # Cutting Instructions Footer
    pdf.fill_color "94A3B8"
    pdf.font("Helvetica", size: 8)
    pdf.text "Instructions: 1. Print on heavy cardstock (250–350 GSM). 2. Cut along the outer dashed lines. 3. Adhere front & back or fold.", align: :center

    pdf.render
  end

  def draw_crop_marks(pdf, x, y, w, h)
    pdf.stroke_color "94A3B8"
    pdf.line_width 0.5
    # Dashed border rectangle as cut guide
    pdf.dash(3, space: 3)
    pdf.stroke_rectangle [x - 2, y + 2], w + 4, h + 4
    pdf.undash
  end

  def fetch_theme_colors
    case @style
    when "clean_light"
      {
        bg: "FFFFFF",
        primary_text: "0F172A",
        secondary_text: "475569",
        accent: accent_hex("2563EB"),
        card_border: "E2E8F0",
        footer_bg: "F8FAFC"
      }
    when "minimalist"
      {
        bg: "0A0A0A",
        primary_text: "FAFAFA",
        secondary_text: "A3A3A3",
        accent: accent_hex("E5E5E5"),
        card_border: "262626",
        footer_bg: "171717"
      }
    when "gradient_aurora"
      {
        bg: "1E1B4B",
        primary_text: "FFFFFF",
        secondary_text: "C7D2FE",
        accent: accent_hex("38BDF8"),
        card_border: "4338CA",
        footer_bg: "312E81"
      }
    when "cyber_glass"
      {
        bg: "09090B",
        primary_text: "F4F4F5",
        secondary_text: "A1A1AA",
        accent: accent_hex("10B981"),
        card_border: "059669",
        footer_bg: "18181B"
      }
    else # modern_dark
      {
        bg: "0F172A",
        primary_text: "F8FAFC",
        secondary_text: "94A3B8",
        accent: accent_hex("6366F1"),
        card_border: "334155",
        footer_bg: "1E293B"
      }
    end
  end

  def accent_hex(fallback)
    config = VisitingCard::COLOR_THEMES[@card.color_theme]
    config ? config[:hex].delete("#").upcase : fallback
  end

  # Draw either Front or Back at arbitrary [origin_x, origin_y]
  def draw_card_face(pdf, origin_x, origin_y, colors, side)
    # Background fill
    pdf.fill_color colors[:bg]
    pdf.fill_rectangle [origin_x, origin_y], CARD_WIDTH, CARD_HEIGHT

    # Border
    pdf.stroke_color colors[:card_border]
    pdf.line_width 0.5
    pdf.stroke_rectangle [origin_x, origin_y], CARD_WIDTH, CARD_HEIGHT

    if side == :front
      draw_front_content(pdf, origin_x, origin_y, colors)
    else
      draw_back_content(pdf, origin_x, origin_y, colors)
    end
  end

  def draw_front_content(pdf, origin_x, origin_y, colors)
    # Accent color vertical bar on left edge
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [origin_x, origin_y], 6, CARD_HEIGHT

    # Inner bounding box for content
    content_x = origin_x + 18
    content_y = origin_y - 14
    content_w = CARD_WIDTH - 28
    content_h = CARD_HEIGHT - 24

    pdf.bounding_box([content_x, content_y], width: content_w, height: content_h) do
      # 1. Company or Tagline Pill
      if @card.company_or_tagline.present?
        pdf.fill_color colors[:accent]
        pdf.font("Helvetica", style: :bold, size: 7.5)
        # Handle long company name gracefully
        clean_tagline = @card.company_or_tagline.strip.truncate(45).upcase
        spacing = clean_tagline.length > 25 ? 0.4 : 1.0
        pdf.text clean_tagline, character_spacing: spacing
        pdf.move_down 4
      end

      # 2. Full Name
      pdf.fill_color colors[:primary_text]
      name_size = @card.full_name.length > 22 ? 12 : 14.5
      pdf.font("Helvetica", style: :bold, size: name_size)
      pdf.text @card.full_name, leading: 2

      # 3. Designation / Title
      if @card.designation.present?
        pdf.fill_color colors[:secondary_text]
        pdf.font("Helvetica", style: :normal, size: 8.5)
        pdf.text @card.designation.strip.truncate(45)
      end

      pdf.move_down 8

      # 4. Subtle hairline separator
      pdf.stroke_color colors[:card_border]
      pdf.line_width 0.5
      pdf.stroke_horizontal_rule
      pdf.move_down 6

      # 5. Direct Contact Channels
      pdf.font("Helvetica", size: 7.2)
      pdf.fill_color colors[:secondary_text]

      if @card.phone.present?
        pdf.text "TEL:  #{@card.phone.strip}", leading: 1.5
      end

      if @card.email.present?
        pdf.text "EMAIL:  #{@card.email.strip}", leading: 1.5
      end

      web = @card.portfolio_url.presence || @card.website_url.presence || @card.linkedin_url.presence
      if web.present?
        display_web = web.sub(%r{\Ahttps?://(www\.)?}, "").strip.truncate(42)
        pdf.text "WEB:  #{display_web}", leading: 1.5
      end
    end
  end

  def draw_back_content(pdf, origin_x, origin_y, colors)
    # Accent horizontal bar along top
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [origin_x, origin_y], CARD_WIDTH, 4

    # QR Code on left
    qr_size = 78.0
    qr_x = origin_x + 18.0
    qr_y = origin_y - 20.0

    # Draw crisp white rounded card backing for QR code
    pdf.fill_color "FFFFFF"
    pdf.fill_rounded_rectangle [qr_x - 4, qr_y + 4], qr_size + 8, qr_size + 8, 4

    # Generate high-contrast PNG QR Code for print
    qr_png_data = @card.qr_code_png(@public_url, size: 280)
    qr_image = StringIO.new(qr_png_data)
    pdf.image qr_image, at: [qr_x, qr_y], width: qr_size, height: qr_size

    # Right side text block
    right_x = qr_x + qr_size + 14.0
    right_width = origin_x + CARD_WIDTH - right_x - 14.0

    pdf.bounding_box([right_x, origin_y - 24], width: right_width, height: CARD_HEIGHT - 36) do
      pdf.fill_color colors[:accent]
      pdf.font("Helvetica", style: :bold, size: 7.5)
      pdf.text "SCAN TO CONNECT", character_spacing: 1

      pdf.move_down 4
      pdf.fill_color colors[:primary_text]
      pdf.font("Helvetica", style: :bold, size: 10.5)
      pdf.text @card.full_name.truncate(22)

      if @card.designation.present?
        pdf.fill_color colors[:secondary_text]
        pdf.font("Helvetica", size: 7.5)
        pdf.text @card.designation.truncate(28)
      end

      pdf.move_down 6
      pdf.fill_color colors[:secondary_text]
      pdf.font("Helvetica", size: 6.5)
      pdf.text "Point camera to save instant contact & open mobile profile.", leading: 2

      pdf.move_down 4
      pdf.fill_color colors[:accent]
      pdf.font("Helvetica", style: :bold, size: 7)
      pdf.text "/c/#{@card.slug.truncate(24)}"
    end
  end
end
