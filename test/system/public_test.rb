require "application_system_test_case"

class PublicTest < ApplicationSystemTestCase
  test "visiting the public index page" do
    visit root_url

    # Check that the page loads with the main title
    assert_selector "h1", text: "Accountingly"
    assert_selector "h2", text: "Simple Accounting for"
    assert_selector "span", text: "Modern Businesses"

    # Check that the sign in link is present
    assert_selector "a", text: "Sign In"

    # Check that the features section is present
    assert_selector "h3", text: "Easy Account Management"
    assert_selector "h3", text: "Transaction Tracking"
    assert_selector "h3", text: "Financial Reports"

    # Check that the CTA section is present
    assert_selector "h3", text: "Ready to get started?"
    assert_selector "a", text: "Sign In Now"
    assert_selector "a", text: "Get Started"
  end

  test "sign in link navigates to session page" do
    visit root_url

    # Click the sign in link in the header
    click_on "Sign In"

    # Should be redirected to the new session page
    assert_current_path new_session_path
  end

  test "get started button navigates to session page" do
    visit root_url

    # Click the "Get Started" button
    click_on "Get Started"

    # Should be redirected to the new session page
    assert_current_path new_session_path
  end

  test "sign in now button navigates to session page" do
    visit root_url

    # Click the "Sign In Now" button in the CTA section
    click_on "Sign In Now"

    # Should be redirected to the new session page
    assert_current_path new_session_path
  end

  test "learn more link scrolls to features section" do
    visit root_url

    # Click the "Learn More" link
    click_on "Learn More"

    # Should stay on the same page (no navigation)
    assert_current_path root_path

    # The features section should be visible
    assert_selector "#features"
  end
end
