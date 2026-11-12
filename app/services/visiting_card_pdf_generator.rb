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
      page_size: [ CARD_WIDTH, CARD_HEIGHT ],
      margin: 0
    )

    theme_colors = fetch_theme_colors

    # PAGE 1: FRONT SIDE
    draw_card_face(pdf, 0, CARD_HEIGHT, theme_colors, :front)

    # PAGE 2: BACK SIDE
    pdf.start_new_page(size: [ CARD_WIDTH, CARD_HEIGHT ], margin: 0)
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
    pdf.stroke_rectangle [ x - 2, y + 2 ], w + 4, h + 4
    pdf.undash
  end

  def fetch_theme_colors
    colors = case @style
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
    when "editorial"
      {
        bg: "F7F5EF",
        primary_text: "282923",
        secondary_text: "62645A",
        accent: accent_hex("686B5E"),
        card_border: "DDDACC",
        footer_bg: "ECEAE2"
      }
    when "botanical"
      {
        bg: "E8F0E7",
        primary_text: "1E362B",
        secondary_text: "50675B",
        accent: accent_hex("668B70"),
        card_border: "C4D6C5",
        footer_bg: "DCE8DC"
      }
    when "terracotta"
      {
        bg: "FCF4EC",
        primary_text: "422E26",
        secondary_text: "7C6256",
        accent: accent_hex("B86E50"),
        card_border: "E8D4C5",
        footer_bg: "F4E5D8"
      }
    when "midnight"
      {
        bg: "14213D",
        primary_text: "F5F1E6",
        secondary_text: "C8C1AC",
        accent: accent_hex("C5A76F"),
        card_border: "3D4B65",
        footer_bg: "202D48"
      }
    when "luxe"
      {
        bg: "151515",
        primary_text: "F4EFE6",
        secondary_text: "A8A095",
        accent: accent_hex("D8BD86"),
        card_border: "403A31",
        footer_bg: "24211D"
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
    colors.merge(
      accent_text: accessible_accent(colors[:accent], [ colors[:bg], colors[:footer_bg] ])
    )
  end

  def accent_hex(fallback)
    config = VisitingCard::COLOR_THEMES[@card.color_theme]
    config ? config[:hex].delete("#").upcase : fallback
  end

  def accessible_accent(accent, backgrounds)
    accent_rgb = accent.scan(/../).map { |channel| channel.to_i(16) }
    background_rgb = backgrounds.map { |background| background.scan(/../).map { |channel| channel.to_i(16) } }

    return accent if background_rgb.all? { |background| contrast_ratio(accent_rgb, background) >= 4.5 }

    luminance = background_rgb.sum { |background| relative_luminance(background) } / background_rgb.size
    target = luminance > 0.5 ? 0 : 255

    (1..100).each do |step|
      candidate = accent_rgb.map { |channel| (channel + (target - channel) * step / 100.0).round }
      return candidate.map { |channel| format("%02X", channel) }.join if background_rgb.all? do |background|
        contrast_ratio(candidate, background) >= 4.5
      end
    end

    accent
  end

  def contrast_ratio(first_rgb, second_rgb)
    first_luminance = relative_luminance(first_rgb)
    second_luminance = relative_luminance(second_rgb)
    ([ first_luminance, second_luminance ].max + 0.05) /
      ([ first_luminance, second_luminance ].min + 0.05)
  end

  def relative_luminance(rgb)
    channels = rgb.map do |channel|
      normalized = channel / 255.0
      normalized <= 0.04045 ? normalized / 12.92 : ((normalized + 0.055) / 1.055)**2.4
    end
    channels.zip([ 0.2126, 0.7152, 0.0722 ]).sum { |channel, weight| channel * weight }
  end

  # Draw either Front or Back at arbitrary [origin_x, origin_y]
  def draw_card_face(pdf, origin_x, origin_y, colors, side)
    # Background fill
    pdf.fill_color colors[:bg]
    pdf.fill_rectangle [ origin_x, origin_y ], CARD_WIDTH, CARD_HEIGHT

    # Border
    pdf.stroke_color colors[:card_border]
    pdf.line_width 0.5
    pdf.stroke_rectangle [ origin_x, origin_y ], CARD_WIDTH, CARD_HEIGHT

    if side == :front
      draw_front_content(pdf, origin_x, origin_y, colors)
    else
      draw_back_content(pdf, origin_x, origin_y, colors)
    end
  end

  def draw_front_content(pdf, origin_x, origin_y, colors)
    case @style
    when "modern_dark"
      draw_front_modern(pdf, origin_x, origin_y, colors)
    when "clean_light", "midnight"
      draw_front_centered(pdf, origin_x, origin_y, colors)
    when "minimalist"
      draw_front_typographic(pdf, origin_x, origin_y, colors)
    when "gradient_aurora", "botanical", "luxe"
      draw_front_panel(pdf, origin_x, origin_y, colors)
    when "cyber_glass"
      draw_front_tech(pdf, origin_x, origin_y, colors)
    when "terracotta"
      draw_front_blocks(pdf, origin_x, origin_y, colors)
    else
      draw_front_editorial(pdf, origin_x, origin_y, colors)
    end
  end

  def draw_front_editorial(pdf, x, y, colors)
    draw_front_motif(pdf, x, y, colors)
    text_x = x + 19
    text_width = CARD_WIDTH - 40

    draw_brand(pdf, text_x, y - 17, text_width - 32, colors)
    draw_monogram(pdf, x + CARD_WIDTH - 36, y - 15, colors)
    draw_name(pdf, text_x, y - 47, text_width, colors, size: 19)
    draw_role(pdf, text_x, y - 70, text_width, colors)
    draw_accent_rule(pdf, text_x, y - 87, colors)
    draw_contact_rows(pdf, text_x, y - 94, text_width, colors)
  end

  def draw_front_modern(pdf, x, y, colors)
    panel_width = 120
    pdf.fill_color colors[:footer_bg]
    pdf.fill_rectangle [ x, y ], panel_width, CARD_HEIGHT
    pdf.fill_color colors[:accent_text]
    pdf.fill_rectangle [ x + panel_width, y ], 3, CARD_HEIGHT

    draw_brand(pdf, x + 13, y - 18, panel_width - 26, colors)
    draw_name(pdf, x + 13, y - 48, panel_width - 26, colors, size: 15)
    draw_role(pdf, x + 13, y - 76, panel_width - 26, colors, size: 7, max_lines: 3, max_height: 25)
    draw_monogram(pdf, x + (panel_width - 22) / 2.0, y - 114, colors)

    contact_x = x + panel_width + 16
    contact_width = CARD_WIDTH - panel_width - 29
    draw_accent_rule(pdf, contact_x, y - 37, colors)
    draw_contact_stack(pdf, contact_x, y - 45, contact_width, colors)
    pdf.fill_color colors[:secondary_text]
    pdf.font("Helvetica", style: :bold, size: 5.2)
    pdf.text_box "DETAILS THAT TRAVEL WITH YOU",
                 at: [ contact_x, y - 126 ],
                 width: contact_width,
                 height: 8,
                 size: 5.2,
                 character_spacing: 0.3,
                 overflow: :shrink_to_fit,
                 single_line: true
  end

  def draw_front_centered(pdf, x, y, colors)
    inset = @style == "midnight" ? 11 : 7
    content_offset = @style == "midnight" ? 6 : 0
    pdf.stroke_color colors[:card_border]
    pdf.line_width @style == "midnight" ? 1.2 : 0.5
    pdf.stroke_rectangle [ x + inset, y - inset ], CARD_WIDTH - inset * 2, CARD_HEIGHT - inset * 2
    draw_monogram(pdf, x + (CARD_WIDTH - 22) / 2.0, y - 16, colors)
    draw_brand(pdf, x + 22, y - 48, CARD_WIDTH - 44, colors, align: :center)
    draw_name(pdf, x + 20, y - 66 + content_offset, CARD_WIDTH - 40, colors, size: 17, align: :center, max_lines: 1)
    draw_role(pdf, x + 20, y - 84 + content_offset, CARD_WIDTH - 40, colors, align: :center)
    draw_contact_rows(pdf, x + 20, y - 97 + content_offset, CARD_WIDTH - 40, colors, row_gap: 9)
  end

  def draw_front_typographic(pdf, x, y, colors)
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [ x, y ], 2, CARD_HEIGHT
    draw_brand(pdf, x + 17, y - 19, 122, colors)
    draw_monogram(pdf, x + CARD_WIDTH - 47, y - 16, colors)

    draw_name(pdf, x + 17, y - 53, 185, colors, size: 20)
    draw_role(pdf, x + 17, y - 75, 190, colors)
    pdf.stroke_color colors[:card_border]
    pdf.line_width 0.6
    pdf.stroke_horizontal_line x + 17, x + CARD_WIDTH - 17, at: y - 91
    draw_contact_rows(pdf, x + 17, y - 96, CARD_WIDTH - 34, colors, row_gap: 9)
  end

  def draw_front_panel(pdf, x, y, colors)
    panel_width = @style == "luxe" ? 73 : 67
    panel_x = @style == "botanical" ? x + CARD_WIDTH - panel_width : x
    pdf.fill_color colors[:footer_bg]
    pdf.fill_rectangle [ panel_x, y ], panel_width, CARD_HEIGHT
    pdf.fill_color colors[:accent]
    rule_x = @style == "botanical" ? panel_x : panel_x + panel_width - 2
    pdf.fill_rectangle [ rule_x, y ], 2, CARD_HEIGHT

    center_x = panel_x + panel_width / 2.0
    pdf.fill_color colors[:bg]
    pdf.fill_circle [ center_x, y - 51 ], 23
    pdf.stroke_color colors[:accent]
    pdf.line_width 1
    pdf.stroke_circle [ center_x, y - 51 ], 23
    pdf.fill_color colors[:accent_text]
    pdf.font("Helvetica", style: :bold, size: 13)
    pdf.text_box @card.initials,
                 at: [ center_x - 17, y - 56 ],
                 width: 34,
                 height: 15,
                 size: 13,
                 align: :center,
                 valign: :center
    pdf.fill_color colors[:secondary_text]
    pdf.font("Helvetica", style: :bold, size: 5.5)
    pdf.text_box "CONNECT",
                 at: [ x + 8, y - 91 ],
                 width: panel_width - 16,
                 height: 9,
                 size: 5.5,
                 align: :center,
                 character_spacing: 0.6

    text_x = @style == "botanical" ? x + 13 : x + panel_width + 13
    text_width = @style == "botanical" ? CARD_WIDTH - panel_width - 25 : CARD_WIDTH - panel_width - 25
    draw_brand(pdf, text_x, y - 20, text_width, colors)
    draw_name(pdf, text_x, y - 51, text_width, colors, size: 16)
    draw_role(pdf, text_x, y - 70, text_width, colors, size: 7)
    draw_accent_rule(pdf, text_x, y - 84, colors)
    draw_contact_rows(pdf, text_x, y - 96, text_width, colors, row_gap: 9)
  end

  def draw_front_tech(pdf, x, y, colors)
    draw_front_motif(pdf, x, y, colors)
    draw_brand(pdf, x + 17, y - 19, CARD_WIDTH - 34, colors)
    draw_name(pdf, x + 17, y - 49, CARD_WIDTH - 34, colors, size: 20)
    draw_role(pdf, x + 17, y - 70, CARD_WIDTH - 34, colors)

    pdf.fill_color colors[:footer_bg]
    pdf.fill_rectangle [ x + 7, y - 89 ], CARD_WIDTH - 14, 48
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [ x + 7, y - 89 ], 2, 48
    draw_contact_rows(pdf, x + 17, y - 96, CARD_WIDTH - 34, colors, row_gap: 9)
  end

  def draw_front_blocks(pdf, x, y, colors)
    pdf.fill_color colors[:footer_bg]
    pdf.fill_rectangle [ x, y ], CARD_WIDTH, CARD_HEIGHT
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [ x, y ], 7, CARD_HEIGHT
    pdf.fill_rectangle [ x, y ], CARD_WIDTH, 3

    draw_brand(pdf, x + 20, y - 21, CARD_WIDTH - 40, colors)
    draw_name(pdf, x + 20, y - 55, CARD_WIDTH - 40, colors, size: 21)
    draw_role(pdf, x + 20, y - 78, CARD_WIDTH - 40, colors, size: 8.5)

    pdf.fill_color colors[:bg]
    pdf.fill_rectangle [ x + 8, y - 91 ], CARD_WIDTH - 8, 91
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [ x + 8, y - 91 ], 2, 91
    draw_contact_rows(pdf, x + 20, y - 96, CARD_WIDTH - 40, colors, row_gap: 9)
  end

  def draw_brand(pdf, x, y, width, colors, align: :left)
    brand = @card.company_or_tagline.presence || "DIGITAL VISITING CARD"
    lines, font_size, height = fit_text_lines(
      pdf,
      brand.strip.upcase,
      width,
      size: 7,
      min_font_size: 5,
      max_lines: 2,
      max_height: 14,
      style: :bold
    )
    pdf.fill_color colors[:accent_text]
    pdf.font("Helvetica", style: :bold, size: font_size)
    pdf.text_box lines.join("\n"),
                 at: [ x, y ],
                 width: width,
                 height: height,
                 size: font_size,
                 min_font_size: font_size,
                 align: align,
                 overflow: :shrink_to_fit,
                 single_line: lines.one?
  end

  def draw_name(pdf, x, y, width, colors, size:, align: :left, max_lines: 2)
    height = size + 8
    lines, font_size, text_height = fit_text_lines(
      pdf,
      @card.full_name.to_s.strip,
      width,
      size: size,
      min_font_size: 5.5,
      max_lines: max_lines,
      max_height: height,
      style: :bold
    )
    pdf.fill_color colors[:primary_text]
    pdf.font("Helvetica", style: :bold, size: font_size)
    pdf.text_box lines.join("\n"),
                 at: [ x, y ],
                 width: width,
                 height: text_height,
                 size: font_size,
                 min_font_size: font_size,
                 style: :bold,
                 align: align,
                 overflow: :shrink_to_fit,
                 single_line: lines.one?
  end

  def draw_fitted_label(pdf, text, x, y, width, color, size:, min_font_size:, height:, align: :left)
    lines, font_size, text_height = fit_text_lines(
      pdf,
      text,
      width,
      size: size,
      min_font_size: min_font_size,
      max_lines: 1,
      max_height: height,
      style: :bold
    )
    pdf.fill_color color
    pdf.font("Helvetica", style: :bold, size: font_size)
    pdf.text_box lines.first,
                 at: [ x, y ],
                 width: width,
                 height: text_height,
                 size: font_size,
                 min_font_size: font_size,
                 align: align,
                 overflow: :shrink_to_fit,
                 single_line: true
  end

  def draw_role(pdf, x, y, width, colors, size: 8, align: :left, max_lines: 1, max_height: size + 5)
    return if @card.designation.blank?

    lines, font_size, text_height = fit_text_lines(
      pdf,
      @card.designation.strip,
      width,
      size: size,
      min_font_size: 5,
      max_lines: max_lines,
      max_height: max_height
    )
    pdf.fill_color colors[:secondary_text]
    pdf.font("Helvetica", size: font_size)
    pdf.text_box lines.join("\n"),
                 at: [ x, y ],
                 width: width,
                 height: text_height,
                 size: font_size,
                 min_font_size: font_size,
                 align: align,
                 overflow: :shrink_to_fit,
                 single_line: lines.one?
  end

  def fit_text_lines(pdf, text, width, size:, min_font_size:, max_lines:, max_height:, style: nil)
    return [ [ "" ], min_font_size, min_font_size + 1 ] if text.blank?

    measure = ->(value, font_size) { pdf.width_of(value, size: font_size, style: style) }
    if measure.call(text, size) <= width
      return [ [ text ], size, [ size * 1.2 + 1, max_height ].min ]
    end

    pieces = text.split(/\s+/).flat_map do |word|
      next [ word ] if measure.call(word, min_font_size) <= width || !word.include?("-")

      segments = word.split("-")
      segments.each_with_index.map { |segment, index| index == segments.length - 1 ? segment : "#{segment}-" }
    end
    lines = []
    current_line = +""

    pieces.each do |piece|
      candidate = [ current_line, piece ].reject(&:empty?).join(" ")
      if current_line.empty? || measure.call(candidate, min_font_size) <= width
        current_line = candidate
      elsif lines.length < max_lines - 1
        lines << current_line
        current_line = piece
      else
        current_line = truncate_to_width(pdf, current_line, width, min_font_size, style) if
          measure.call(candidate, min_font_size) > width
        break
      end
    end
    lines << current_line unless current_line.empty?
    lines = lines.first(max_lines)
    lines[-1] = truncate_to_width(pdf, lines[-1], width, min_font_size, style) if
      lines[-1] && measure.call(lines[-1], min_font_size) > width

    widest_line = lines.map { |line| measure.call(line, size) }.max || 0
    font_size = [ size, size * [ width - 1, 0 ].max / [ widest_line, 1 ].max ].min
    font_size = [ font_size, max_height / (lines.length * 1.2 + 0.2) ].min
    font_size = [ font_size, min_font_size ].max
    text_height = [ font_size * lines.length * 1.2 + 1, max_height ].min
    [ lines, font_size, text_height ]
  end

  def truncate_to_width(pdf, text, width, font_size, style)
    suffix = "…"
    characters = text.each_char.to_a
    characters.pop while characters.any? && pdf.width_of("#{characters.join}#{suffix}", size: font_size, style: style) > width
    "#{characters.join}#{suffix}"
  end

  def draw_accent_rule(pdf, x, y, colors)
    pdf.fill_color colors[:accent]
    pdf.fill_rounded_rectangle [ x, y ], 28, 2, 1
  end

  def contact_details
    [
      [ "TEL", @card.phone ],
      [ "EMAIL", @card.email ],
      [ "WEB", @card.portfolio_url.presence || @card.website_url.presence || @card.linkedin_url ]
    ].select { |_, value| value.present? }
  end

  def formatted_contact(label, value)
    label == "WEB" ? value.to_s.sub(%r{\Ahttps?://(www\.)?}, "") : value.to_s.strip
  end

  def slug_label(pdf, width, size:)
    value = "/c/#{@card.slug}"
    return value if pdf.width_of(value, size: size) <= width

    segments = @card.slug.split("-")
    visible_slug = +""
    segments.each do |segment|
      candidate = [ visible_slug, segment ].reject(&:empty?).join("-")
      break if pdf.width_of("/c/#{candidate}…", size: size) > width

      visible_slug = candidate
    end
    "/c/#{visible_slug}…"
  end

  def draw_contact_rows(pdf, x, top_y, width, colors, row_gap: 11)
    pdf.stroke_color colors[:card_border]
    pdf.line_width 0.6
    pdf.stroke_horizontal_line x, x + width, at: top_y + 1

    contact_details.first(3).each_with_index do |(label, value), index|
      row_y = top_y - 12 - (index * row_gap)
      pdf.fill_color colors[:accent_text]
      pdf.font("Helvetica", style: :bold, size: 5.8)
      pdf.text_box label,
                   at: [ x, row_y ],
                   width: 31,
                   height: 8,
                   size: 5.8,
                   character_spacing: 0.3,
                   single_line: true
      pdf.fill_color colors[:secondary_text]
      pdf.text_box formatted_contact(label, value),
                   at: [ x + 35, row_y ],
                   width: width - 35,
                   height: 8,
                   size: 6.8,
                   min_font_size: 4.5,
                   overflow: :shrink_to_fit,
                   single_line: true
    end
  end

  def draw_contact_stack(pdf, x, top_y, width, colors, row_gap: 25)
    contact_details.first(3).each_with_index do |(label, value), index|
      label_y = top_y - (index * row_gap)
      pdf.fill_color colors[:accent_text]
      pdf.font("Helvetica", style: :bold, size: 5.2)
      pdf.text_box label,
                   at: [ x, label_y ],
                   width: width,
                   height: 7,
                   size: 5.2,
                   single_line: true
      pdf.fill_color colors[:secondary_text]
      pdf.text_box formatted_contact(label, value),
                   at: [ x, label_y - 8 ],
                   width: width,
                   height: 8,
                   size: 6,
                   min_font_size: 4.5,
                   overflow: :shrink_to_fit,
                   single_line: true
    end
  end

  def draw_front_motif(pdf, origin_x, origin_y, colors)
    pdf.stroke_color colors[:card_border]
    pdf.line_width 0.6
    pdf.stroke_rectangle [ origin_x + 5, origin_y - 5 ], CARD_WIDTH - 10, CARD_HEIGHT - 10

    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [ origin_x, origin_y ], @style == "editorial" ? 2.5 : 5, CARD_HEIGHT
  end

  def draw_monogram(pdf, x, y, colors)
    size = 22
    if @style == "botanical"
      pdf.fill_color colors[:footer_bg]
      pdf.fill_circle [ x + size / 2.0, y - size / 2.0 ], size / 2.0
    else
      pdf.fill_color colors[:footer_bg]
      pdf.fill_rounded_rectangle [ x, y ], size, size, @style == "editorial" ? 1 : 5
    end

    pdf.fill_color colors[:accent_text]
    pdf.font("Helvetica", style: :bold, size: 8)
    pdf.text_box @card.initials,
                 at: [ x, y - 7 ],
                 width: size,
                 height: 10,
                 size: 8,
                 align: :center,
                 valign: :center
  end

  def draw_back_content(pdf, origin_x, origin_y, colors)
    case @style
    when "modern_dark"
      draw_back_modern(pdf, origin_x, origin_y, colors)
    when "clean_light", "minimalist", "midnight"
      draw_back_centered(pdf, origin_x, origin_y, colors)
    when "gradient_aurora"
      draw_back_aurora(pdf, origin_x, origin_y, colors)
    when "botanical"
      draw_back_botanical(pdf, origin_x, origin_y, colors)
    when "luxe"
      draw_back_panel(pdf, origin_x, origin_y, colors)
    when "cyber_glass"
      draw_back_tech(pdf, origin_x, origin_y, colors)
    when "terracotta"
      draw_back_blocks(pdf, origin_x, origin_y, colors)
    else
      draw_back_editorial(pdf, origin_x, origin_y, colors)
    end
  end

  def draw_back_modern(pdf, x, y, colors)
    panel_width = 44
    pdf.fill_color colors[:footer_bg]
    pdf.fill_rectangle [ x + CARD_WIDTH - panel_width, y ], panel_width, CARD_HEIGHT
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [ x + CARD_WIDTH - panel_width, y ], 3, CARD_HEIGHT
    draw_qr_code(pdf, x + 17, y - 28, 78, colors)

    text_x = x + 110
    text_width = CARD_WIDTH - 110 - panel_width - 8
    draw_fitted_label(pdf, "SCAN TO CONNECT", text_x, y - 34, text_width, colors[:accent_text],
                      size: 6.5, min_font_size: 5, height: 9)
    draw_name(pdf, text_x, y - 57, text_width, colors, size: 10)
    draw_role(pdf, text_x, y - 76, text_width, colors, size: 6, max_lines: 3, max_height: 20)
    pdf.stroke_color colors[:card_border]
    pdf.line_width 0.6
    pdf.stroke_horizontal_line text_x, text_x + text_width, at: y - 96
    pdf.fill_color colors[:secondary_text]
    pdf.text_box "Open your profile. Save your contact.",
                 at: [ text_x, y - 105 ],
                 width: text_width,
                 height: 15,
                 size: 5.5,
                 min_font_size: 4.8,
                 overflow: :shrink_to_fit
    pdf.fill_color colors[:accent_text]
    pdf.text_box slug_label(pdf, text_width, size: 5.5),
                 at: [ text_x, y - 127 ],
                 width: text_width,
                 height: 9,
                 size: 5.5,
                 overflow: :shrink_to_fit,
                 single_line: true
  end

  def draw_back_botanical(pdf, x, y, colors)
    panel_width = 47
    pdf.fill_color colors[:footer_bg]
    pdf.fill_rectangle [ x + CARD_WIDTH - panel_width, y ], panel_width, CARD_HEIGHT
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [ x + CARD_WIDTH - panel_width, y ], 2, CARD_HEIGHT
    draw_monogram(pdf, x + CARD_WIDTH - panel_width + 12, y - 25, colors)
    pdf.fill_color colors[:secondary_text]
    pdf.font("Helvetica", style: :bold, size: 5)
    pdf.text_box "SCAN",
                 at: [ x + CARD_WIDTH - panel_width + 7, y - 63 ],
                 width: panel_width - 14,
                 height: 8,
                 size: 5,
                 align: :center,
                 character_spacing: 0.5

    draw_qr_code(pdf, x + 14, y - 32, 75, colors)
    text_x = x + 100
    text_width = CARD_WIDTH - 100 - panel_width - 8
    pdf.fill_color colors[:accent_text]
    pdf.font("Helvetica", style: :bold, size: 5.8)
    pdf.text_box "KEEP IN TOUCH",
                 at: [ text_x, y - 39 ],
                 width: text_width,
                 height: 9,
                 size: 5.8,
                 character_spacing: 0.3,
                 overflow: :shrink_to_fit,
                 single_line: true
    draw_name(pdf, text_x, y - 60, text_width, colors, size: 9)
    draw_role(pdf, text_x, y - 78, text_width, colors, size: 5.8, max_lines: 3, max_height: 19)
    pdf.fill_color colors[:secondary_text]
    pdf.text_box slug_label(pdf, text_width, size: 5.5),
                 at: [ text_x, y - 107 ],
                 width: text_width,
                 height: 18,
                 size: 5.5,
                 overflow: :shrink_to_fit,
                 single_line: true
  end

  def draw_back_centered(pdf, x, y, colors)
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [ x, y ], CARD_WIDTH, @style == "midnight" ? 3 : 1.5
    qr_size = 60
    draw_qr_code(pdf, x + (CARD_WIDTH - qr_size) / 2.0, y - 36, qr_size, colors)
    pdf.fill_color colors[:accent_text]
    pdf.font("Helvetica", style: :bold, size: 6.5)
    draw_brand(pdf, x + 18, y - 18, CARD_WIDTH - 36, colors, align: :center)
    draw_name(pdf, x + 15, y - 110, CARD_WIDTH - 30, colors, size: 10, align: :center, max_lines: 1)
    pdf.fill_color colors[:secondary_text]
    pdf.text_box slug_label(pdf, CARD_WIDTH - 30, size: 6),
                 at: [ x + 15, y - 130 ],
                 width: CARD_WIDTH - 30,
                 height: 8,
                 size: 6,
                 overflow: :shrink_to_fit,
                 single_line: true,
                 align: :center
  end

  def draw_back_panel(pdf, x, y, colors)
    panel_width = 62
    pdf.fill_color colors[:footer_bg]
    pdf.fill_rectangle [ x, y ], panel_width, CARD_HEIGHT
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [ x + panel_width - 2, y ], 2, CARD_HEIGHT
    draw_monogram(pdf, x + (panel_width - 22) / 2.0, y - 21, colors)
    pdf.fill_color colors[:secondary_text]
    pdf.font("Helvetica", style: :bold, size: 5.5)
    pdf.text_box "SCAN TO",
                 at: [ x + 8, y - 59 ],
                 width: panel_width - 16,
                 height: 8,
                 size: 5.5,
                 align: :center,
                 character_spacing: 0.4
    pdf.text_box "CONNECT",
                 at: [ x + 8, y - 68 ],
                 width: panel_width - 16,
                 height: 8,
                 size: 5.5,
                 align: :center,
                 character_spacing: 0.4

    qr_x = x + 153
    draw_qr_code(pdf, qr_x, y - 29, 78, colors)
    text_x = x + panel_width + 12
    text_width = qr_x - text_x - 8
    draw_name(pdf, text_x, y - 43, text_width, colors, size: 11)
    draw_role(pdf, text_x, y - 67, text_width, colors, size: 6.5, max_lines: 3, max_height: 19)
    pdf.stroke_color colors[:card_border]
    pdf.line_width 0.6
    pdf.stroke_horizontal_line text_x, text_x + text_width, at: y - 90
    pdf.fill_color colors[:secondary_text]
    pdf.text_box "Save this card to your phone.",
                 at: [ text_x, y - 99 ],
                 width: text_width,
                 height: 14,
                 size: 6,
                 min_font_size: 5,
                 overflow: :shrink_to_fit
    pdf.fill_color colors[:accent_text]
    pdf.text_box slug_label(pdf, text_width, size: 6),
                 at: [ text_x, y - 124 ],
                 width: text_width,
                 height: 9,
                 size: 6,
                 overflow: :shrink_to_fit,
                 single_line: true
  end

  def draw_back_aurora(pdf, x, y, colors)
    pdf.fill_color colors[:footer_bg]
    pdf.fill_rectangle [ x, y ], CARD_WIDTH, CARD_HEIGHT
    pdf.fill_color colors[:accent]
    pdf.fill_circle [ x + CARD_WIDTH - 18, y - 17 ], 12
    pdf.fill_circle [ x + CARD_WIDTH - 18, y - 17 ], 6
    draw_qr_code(pdf, x + 17, y - 29, 80, colors)
    text_x = x + 116
    text_width = CARD_WIDTH - (text_x - x) - 16
    draw_brand(pdf, text_x, y - 34, text_width, colors)
    draw_name(pdf, text_x, y - 56, text_width, colors, size: 11)
    draw_role(pdf, text_x, y - 76, text_width, colors, size: 6.5, max_lines: 2, max_height: 14)
    pdf.fill_color colors[:secondary_text]
    pdf.text_box "One scan opens your digital profile.",
                 at: [ text_x, y - 96 ],
                 width: text_width,
                 height: 20,
                 size: 5.8,
                 min_font_size: 5,
                 overflow: :shrink_to_fit
    pdf.fill_color colors[:accent_text]
    pdf.text_box slug_label(pdf, text_width, size: 5.5),
                 at: [ text_x, y - 122 ],
                 width: text_width,
                 height: 9,
                 size: 5.5,
                 overflow: :shrink_to_fit,
                 single_line: true
  end

  def draw_back_tech(pdf, x, y, colors)
    pdf.fill_color colors[:footer_bg]
    pdf.fill_rectangle [ x, y ], CARD_WIDTH, CARD_HEIGHT
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [ x, y ], 4, CARD_HEIGHT
    pdf.fill_rectangle [ x, y ], CARD_WIDTH, 4
    draw_qr_code(pdf, x + 15, y - 27, 76, colors)

    text_x = x + 107
    text_width = CARD_WIDTH - 122
    draw_brand(pdf, text_x, y - 30, text_width, colors)
    draw_name(pdf, text_x, y - 52, text_width, colors, size: 11)
    draw_role(pdf, text_x, y - 70, text_width, colors, size: 6.5, max_lines: 2, max_height: 14)

    pdf.stroke_color colors[:card_border]
    pdf.line_width 0.6
    pdf.stroke_horizontal_line text_x, x + CARD_WIDTH - 13, at: y - 83
    pdf.fill_color colors[:accent_text]
    pdf.font("Helvetica", style: :bold, size: 6)
    pdf.text_box "SCAN  /  SAVE  /  CONNECT",
                 at: [ text_x, y - 97 ],
                 width: text_width,
                 height: 9,
                 size: 6,
                 character_spacing: 0.3,
                 overflow: :shrink_to_fit
    pdf.fill_color colors[:secondary_text]
    pdf.text_box slug_label(pdf, text_width, size: 6),
                 at: [ text_x, y - 117 ],
                 width: text_width,
                 height: 10,
                 size: 6,
                 overflow: :shrink_to_fit,
                 single_line: true
  end

  def draw_back_blocks(pdf, x, y, colors)
    pdf.fill_color colors[:footer_bg]
    pdf.fill_rectangle [ x, y ], CARD_WIDTH, CARD_HEIGHT
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [ x, y ], CARD_WIDTH, 5
    draw_qr_code(pdf, x + 18, y - 31, 74, colors)

    text_x = x + 108
    text_width = CARD_WIDTH - 126
    draw_brand(pdf, text_x, y - 34, text_width, colors)
    draw_name(pdf, text_x, y - 57, text_width, colors, size: 12)
    draw_role(pdf, text_x, y - 76, text_width, colors, size: 7, max_lines: 3, max_height: 20)
    pdf.fill_color colors[:bg]
    pdf.fill_rectangle [ x + 6, y - 104 ], CARD_WIDTH - 12, 30
    pdf.fill_color colors[:accent_text]
    pdf.font("Helvetica", style: :bold, size: 6)
    pdf.text_box "SCAN TO SAVE YOUR CONTACT",
                 at: [ x + 16, y - 120 ],
                 width: CARD_WIDTH - 32,
                 height: 8,
                 size: 6,
                 character_spacing: 0.5,
                 single_line: true
    pdf.text_box slug_label(pdf, CARD_WIDTH - 32, size: 5.5),
                 at: [ x + 16, y - 131 ],
                 width: CARD_WIDTH - 32,
                 height: 7,
                 size: 5.5,
                 overflow: :shrink_to_fit,
                 single_line: true
  end

  def draw_back_editorial(pdf, origin_x, origin_y, colors)
    # Color band and inset frame visually tie the reverse to the front.
    pdf.fill_color colors[:accent]
    pdf.fill_rectangle [ origin_x, origin_y ], CARD_WIDTH, 5
    pdf.stroke_color colors[:card_border]
    pdf.line_width 0.6
    pdf.stroke_rectangle [ origin_x + 5, origin_y - 5 ], CARD_WIDTH - 10, CARD_HEIGHT - 10

    # Keep a generous quiet zone around the QR for dependable scanning in print.
    qr_size = 82.0
    qr_x = origin_x + 17.0
    qr_y = origin_y - 26.0

    draw_qr_code(pdf, qr_x, qr_y, qr_size, colors)

    right_x = origin_x + 121
    right_width = CARD_WIDTH - (right_x - origin_x) - 16

    pdf.fill_color colors[:accent_text]
    pdf.font("Helvetica", style: :bold, size: 7)
    pdf.text_box "YOUR DETAILS, ONE SCAN AWAY",
                 at: [ right_x, origin_y - 31 ],
                 width: right_width,
                 height: 11,
                 size: 7,
                 character_spacing: 0.5,
                 overflow: :shrink_to_fit,
                 single_line: true

    draw_name(pdf, right_x, origin_y - 51, right_width, colors, size: 12)
    draw_role(pdf, right_x, origin_y - 72, right_width, colors, size: 7.5, max_lines: 2, max_height: 14)

    pdf.stroke_color colors[:card_border]
    pdf.line_width 0.6
    pdf.stroke_horizontal_line right_x, right_x + right_width, at: origin_y - 86

    pdf.fill_color colors[:secondary_text]
    pdf.text_box "Scan to open your profile and save your contact.",
                 at: [ right_x, origin_y - 91 ],
                 width: right_width,
                 height: 25,
                 size: 6.5,
                 min_font_size: 5.5,
                 leading: 2,
                 overflow: :shrink_to_fit

    pdf.fill_color colors[:accent_text]
    pdf.font("Helvetica", style: :bold, size: 6.5)
    pdf.text_box slug_label(pdf, right_width, size: 6.5),
                 at: [ right_x, origin_y - 119 ],
                 width: right_width,
                 height: 11,
                 size: 6.5,
                 overflow: :shrink_to_fit,
                 single_line: true

    pdf.fill_color colors[:footer_bg]
    pdf.fill_rectangle [ origin_x + 5, origin_y - CARD_HEIGHT + 17 ], CARD_WIDTH - 10, 12
    pdf.fill_color colors[:secondary_text]
    pdf.font("Helvetica", style: :bold, size: 5.5)
    pdf.text_box "CARDFORGE  /  DIGITAL CONTACT",
                 at: [ origin_x + 14, origin_y - CARD_HEIGHT + 14 ],
                 width: CARD_WIDTH - 28,
                 height: 8,
                 size: 5.5,
                 character_spacing: 0.5
  end

  def draw_qr_code(pdf, x, top_y, size, colors)
    quiet_zone = 5
    pdf.fill_color "FFFFFF"
    pdf.fill_rounded_rectangle [ x - quiet_zone, top_y + quiet_zone ], size + quiet_zone * 2, size + quiet_zone * 2, 4
    pdf.stroke_color colors[:card_border]
    pdf.line_width 0.6
    pdf.stroke_rounded_rectangle [ x - quiet_zone, top_y + quiet_zone ], size + quiet_zone * 2, size + quiet_zone * 2, 4

    qr_png_data = @card.qr_code_png(@public_url, size: 320)
    pdf.image StringIO.new(qr_png_data), at: [ x, top_y ], width: size, height: size
  end
end
