class VisitingCard < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :user
  has_one_attached :avatar
  has_one_attached :resume

  def has_resume?
    resume.attached? || resume_url.present?
  end

  TEMPLATE_STYLES = {
    "modern_dark" => {
      name: "Modern Dark",
      description: "Dark obsidian theme with neon accents and sleek contrast",
      bg_class: "bg-slate-900 text-slate-100",
      card_bg: "bg-slate-800/90 border border-slate-700/80 shadow-2xl backdrop-blur-xl",
      accent: "text-indigo-400"
    },
    "clean_light" => {
      name: "Clean Light",
      description: "Crisp white minimalist business card with subtle soft shadows",
      bg_class: "bg-slate-50 text-slate-900",
      card_bg: "bg-white border border-slate-200/90 shadow-xl",
      accent: "text-blue-600"
    },
    "minimalist" => {
      name: "Minimalist Mono",
      description: "Timeless Swiss editorial monochrome layout with hairline borders",
      bg_class: "bg-neutral-950 text-neutral-100",
      card_bg: "bg-black border border-neutral-800 shadow-xl",
      accent: "text-neutral-300"
    },
    "gradient_aurora" => {
      name: "Aurora Mesh",
      description: "Vibrant aurora violet and cyan mesh gradient with glassmorphism",
      bg_class: "bg-gradient-to-br from-indigo-950 via-purple-900 to-slate-950 text-white",
      card_bg: "bg-white/10 border border-white/20 shadow-2xl backdrop-blur-2xl text-white",
      accent: "text-cyan-300"
    },
    "cyber_glass" => {
      name: "Cyber Emerald",
      description: "Modern tech aesthetic with emerald accents and carbon glass finish",
      bg_class: "bg-zinc-950 text-zinc-100",
      card_bg: "bg-zinc-900/90 border border-emerald-500/30 shadow-2xl backdrop-blur-xl",
      accent: "text-emerald-400"
    },
    "editorial" => {
      name: "Quiet Editorial",
      description: "Warm paper, refined type, and an understated editorial layout",
      bg_class: "bg-stone-100 text-stone-900",
      card_bg: "bg-stone-50 border border-stone-200 shadow-xl",
      accent: "text-stone-700"
    },
    "botanical" => {
      name: "Soft Botanical",
      description: "A calm sage palette inspired by nature and thoughtful craft",
      bg_class: "bg-emerald-950 text-emerald-50",
      card_bg: "bg-emerald-900/90 border border-emerald-700 shadow-2xl",
      accent: "text-emerald-300"
    },
    "terracotta" => {
      name: "Warm Terracotta",
      description: "Soft cream and clay tones for a warm, personal impression",
      bg_class: "bg-orange-50 text-stone-900",
      card_bg: "bg-orange-50 border border-orange-200 shadow-xl",
      accent: "text-orange-800"
    },
    "midnight" => {
      name: "Midnight Gold",
      description: "Deep blue with restrained gold details for a polished finish",
      bg_class: "bg-slate-950 text-slate-100",
      card_bg: "bg-slate-900 border border-amber-400/30 shadow-2xl",
      accent: "text-amber-300"
    },
    "luxe" => {
      name: "Luxe Onyx",
      description: "A dramatic onyx canvas with elegant, high-contrast accents",
      bg_class: "bg-neutral-950 text-neutral-100",
      card_bg: "bg-neutral-900 border border-neutral-700 shadow-2xl",
      accent: "text-amber-200"
    }
  }.freeze

  COLOR_THEMES = {
    "indigo" => { name: "Indigo", hex: "#6366f1", badge: "bg-indigo-600" },
    "emerald" => { name: "Emerald", hex: "#10b981", badge: "bg-emerald-700" },
    "violet" => { name: "Violet", hex: "#8b5cf6", badge: "bg-violet-700" },
    "sky" => { name: "Sky Blue", hex: "#0ea5e9", badge: "bg-sky-700" },
    "rose" => { name: "Rose", hex: "#f43f5e", badge: "bg-rose-700" },
    "amber" => { name: "Amber Gold", hex: "#f59e0b", badge: "bg-amber-700" }
  }.freeze

  validates :full_name, presence: true, length: { maximum: 100 }
  validates :card_title, presence: true, length: { maximum: 100 }
  validates :designation, length: { maximum: 100 }
  validates :company_or_tagline, length: { maximum: 140 }
  validates :bio, length: { maximum: 1200 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :template_style, inclusion: { in: TEMPLATE_STYLES.keys }
  validates :color_theme, inclusion: { in: COLOR_THEMES.keys }
  validates :slug, presence: true, uniqueness: true

  # Slugging setup
  def slug_candidates
    [
      :custom_slug,
      :full_name,
      [ :full_name, :company_or_tagline ],
      [ :full_name, -> { SecureRandom.hex(3) } ]
    ]
  end

  def custom_slug
    slug.presence
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

  # Helpers
  def initials
    parts = full_name.to_s.strip.split(/\s+/)
    if parts.size >= 2
      "#{parts.first[0]}#{parts.last[0]}".upcase
    elsif parts.size == 1
      parts.first[0..1].upcase
    else
      "VC"
    end
  end

  def template_config
    TEMPLATE_STYLES[template_style] || TEMPLATE_STYLES["modern_dark"]
  end

  def color_config
    COLOR_THEMES[color_theme] || COLOR_THEMES["indigo"]
  end

  def whatsapp_url(message: nil)
    return nil if phone.blank?
    clean_number = phone.gsub(/[^0-9]/, "")
    msg = message || "Hi #{full_name}, I saw your digital visiting card and would like to connect!"
    "https://wa.me/#{clean_number}?text=#{CGI.escape(msg)}"
  end

  def qr_code_svg(target_url, module_size: 5)
    qrcode = RQRCode::QRCode.new(target_url)
    qrcode.as_svg(
      offset: 0,
      color: "000000",
      shape_rendering: "crispEdges",
      module_size: module_size,
      standalone: true,
      use_path: true
    )
  end

  def qr_code_png(target_url, size: 400)
    qrcode = RQRCode::QRCode.new(target_url)
    qrcode.as_png(
      resize_gte_to: false,
      resize_exactly_to: size,
      fill: "white",
      color: "black"
    ).to_s
  end

  def to_vcf(public_url = nil)
    names = full_name.to_s.strip.split(/\s+/, 2)
    first_name = names.first || ""
    last_name = names.second || ""

    lines = [
      "BEGIN:VCARD",
      "VERSION:3.0",
      "FN:#{full_name}",
      "N:#{last_name};#{first_name};;;",
      ("TITLE:#{designation}" if designation.present?),
      ("ORG:#{company_or_tagline}" if company_or_tagline.present?),
      ("TEL;TYPE=CELL,VOICE:#{phone}" if phone.present?),
      ("EMAIL;TYPE=PREF,INTERNET:#{email}" if email.present?),
      ("URL:#{portfolio_url.presence || website_url.presence || public_url}" if portfolio_url.present? || website_url.present? || public_url.present?),
      ("X-SOCIALPROFILE;TYPE=linkedin:#{linkedin_url}" if linkedin_url.present?),
      ("X-SOCIALPROFILE;TYPE=github:#{github_url}" if github_url.present?),
      ("X-SOCIALPROFILE;TYPE=instagram:#{instagram_url}" if instagram_url.present?),
      ("NOTE:#{bio.to_s.gsub("\n", ' ')}" if bio.present?),
      "REV:#{updated_at&.utc&.strftime('%Y%m%dT%H%M%SZ') || Time.now.utc.strftime('%Y%m%dT%H%M%SZ')}",
      "END:VCARD"
    ].compact

    lines.join("\r\n") + "\r\n"
  end
end
