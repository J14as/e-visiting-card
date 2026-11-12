require "test_helper"

class VisitingCardTest < ActiveSupport::TestCase
  def setup
    @user = users(:one) || User.create!(email: "test@example.com", password: "password123")
    @card = VisitingCard.create!(
      user: @user,
      card_title: "My Work Card",
      full_name: "Jane Doe",
      designation: "Lead Engineer",
      company_or_tagline: "Acme Corp",
      bio: "Software architect and tech lead.",
      phone: "+15551234567",
      email: "jane@example.com",
      portfolio_url: "https://janedoe.dev",
      linkedin_url: "https://linkedin.com/in/janedoe",
      github_url: "https://github.com/janedoe",
      template_style: "modern_dark",
      color_theme: "indigo"
    )
  end

  test "validates full_name presence" do
    card = VisitingCard.new(user: @user, card_title: "Title")
    assert_not card.valid?
    assert_includes card.errors[:full_name], "can't be blank"
  end

  test "generates unique friendly slug from full_name automatically" do
    assert_not_nil @card.slug
    assert_equal "jane-doe", @card.slug
  end

  test "generates valid SVG QR code" do
    svg = @card.qr_code_svg("https://cardforge.io/c/#{@card.slug}")
    assert svg.include?("<svg")
    assert svg.include?("</svg>")
  end

  test "generates valid PNG QR code bytes" do
    png = @card.qr_code_png("https://cardforge.io/c/#{@card.slug}")
    assert png.start_with?("\x89PNG".b)
  end

  test "generates compliant vCard string" do
    vcf = @card.to_vcf
    assert vcf.include?("BEGIN:VCARD")
    assert vcf.include?("FN:Jane Doe")
    assert vcf.include?("TITLE:Lead Engineer")
    assert vcf.include?("ORG:Acme Corp")
    assert vcf.include?("TEL;TYPE=CELL,VOICE:+15551234567")
    assert vcf.include?("EMAIL;TYPE=PREF,INTERNET:jane@example.com")
    assert vcf.include?("END:VCARD")
  end

  test "computes initials properly" do
    assert_equal "JD", @card.initials
    @card.full_name = "Cher"
    assert_equal "CH", @card.initials
  end

  test "supports all ten card styles in print-ready PDFs" do
    assert_equal 10, VisitingCard::TEMPLATE_STYLES.size

    VisitingCard::TEMPLATE_STYLES.each_key do |style|
      @card.template_style = style
      pdf = VisitingCardPdfGenerator.render(@card, "https://cardforge.io/c/#{@card.slug}")

      assert pdf.start_with?("%PDF"), "Expected a valid PDF for the #{style} template"
      assert_includes pdf, "/Count 2", "Expected front and back pages for the #{style} template"
      assert_includes pdf, "/Subtype /Image", "Expected the QR image for the #{style} template"
    end
  end
end
