require "application_system_test_case"

class BusinessesTest < ApplicationSystemTestCase
  setup do
    @business = businesses(:one)
  end

  test "visiting the index" do
    visit businesses_url
    assert_selector "h1", text: "Businesses"
  end

  test "should create business" do
    visit businesses_url
    click_on "New business"

    fill_in "Description", with: @business.description
    fill_in "Title", with: @business.title
    fill_in "Website url", with: @business.website_url
    click_on "Create Business"

    assert_text "Business was successfully created"
    click_on "Back"
  end

  test "should update Business" do
    visit business_url(@business)
    click_on "Edit this business", match: :first

    fill_in "Description", with: @business.description
    fill_in "Title", with: @business.title
    fill_in "Website url", with: @business.website_url
    click_on "Update Business"

    assert_text "Business was successfully updated"
    click_on "Back"
  end

  test "should destroy Business" do
    visit business_url(@business)
    accept_confirm { click_on "Destroy this business", match: :first }

    assert_text "Business was successfully destroyed"
  end
end
