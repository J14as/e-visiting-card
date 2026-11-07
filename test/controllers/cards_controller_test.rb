require "test_helper"

class CardsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @other_user = users(:two)
    @card = visiting_cards(:one)
  end

  test "should redirect unauthenticated user from dashboard to sign in" do
    get dashboard_url
    assert_redirected_to new_user_session_path
  end

  test "should get dashboard when signed in" do
    sign_in @user
    get dashboard_url
    assert_response :success
    assert_select "h1", text: "Your Digital Visiting Cards"
  end

  test "should get new card page" do
    sign_in @user
    get new_card_url
    assert_response :success
  end

  test "should create visiting card" do
    sign_in @user
    assert_difference("VisitingCard.count") do
      post cards_url, params: {
        visiting_card: {
          card_title: "Tech Networking",
          full_name: "Sarah Connor",
          designation: "Security Consultant",
          company_or_tagline: "Cyberdyne Systems",
          template_style: "cyber_glass",
          color_theme: "emerald",
          email: "sarah@example.com"
        }
      }
    end

    created_card = VisitingCard.last
    assert_redirected_to edit_card_url(created_card)
    assert_equal "sarah-connor", created_card.slug
  end

  test "should download card PDF for owner" do
    sign_in @user
    get download_pdf_card_url(@card)
    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert response.body.start_with?("%PDF")
  end

  test "should duplicate card" do
    sign_in @user
    assert_difference("VisitingCard.count") do
      post duplicate_card_url(@card)
    end
    dup_card = VisitingCard.last
    assert_includes dup_card.card_title, "(Copy)"
    assert_redirected_to edit_card_url(dup_card)
  end

  test "should destroy card" do
    sign_in @user
    assert_difference("VisitingCard.count", -1) do
      delete card_url(@card)
    end
    assert_redirected_to dashboard_url
  end
end

