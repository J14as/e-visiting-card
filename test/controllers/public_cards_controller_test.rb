require "test_helper"

class PublicCardsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @card = visiting_cards(:one)
  end

  test "should show public card by slug" do
    get public_card_url(@card.slug)
    assert_response :success
    assert_select "h1", text: @card.full_name
    assert_select "a[href=?]", public_card_vcard_path(@card.slug)
  end

  test "should download vcard file" do
    get public_card_vcard_url(@card.slug)
    assert_response :success
    assert_equal "text/vcard", response.media_type
    assert_includes response.body, "BEGIN:VCARD"
    assert_includes response.body, "FN:#{@card.full_name}"
  end

  test "should download visiting card PDF" do
    get public_card_pdf_url(@card.slug)
    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert response.body.start_with?("%PDF")
  end

  test "should download visiting card print sheet PDF" do
    get public_card_pdf_url(@card.slug, layout: :sheet)
    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert response.body.start_with?("%PDF")
  end

  test "should render QR code image" do
    get public_card_qr_url(@card.slug, fmt: :png)
    assert_response :success
    assert_equal "image/png", response.media_type

    get public_card_qr_url(@card.slug, fmt: :svg)
    assert_response :success
    assert_equal "image/svg+xml", response.media_type
  end

  test "should download attached resume" do
    @card.resume.attach(
      io: StringIO.new("Dummy resume PDF content"),
      filename: "alex-resume.pdf",
      content_type: "application/pdf"
    )
    get public_card_resume_url(@card.slug)
    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_equal "Dummy resume PDF content", response.body
  end

  test "should redirect to resume_url if external link" do
    @card.update!(resume_url: "https://example.com/resume.pdf")
    get public_card_resume_url(@card.slug)
    assert_redirected_to "https://example.com/resume.pdf"
  end

  test "should render 404 for unknown slug" do
    get public_card_url("unknown-slug-xyz")
    assert_response :not_found
  end
end
