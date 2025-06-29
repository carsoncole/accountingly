require "test_helper"

class EntitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in
  end

  test "should not get index" do
    Current.session.destroy
    cookies.delete(:session_id)
    get entities_url
    assert_redirected_to new_session_url
  end

  test "should get index" do
    get entities_url
    assert_response :success
  end

  test "should get show" do
    get entity_url(entities(:ajax_company))
    assert_response :success
  end

  test "should get edit" do
    get edit_entity_url(entities(:ajax_company))
    assert_response :success
  end

  test "should get new" do
    get new_entity_url
    assert_response :success
  end

  test "should get update" do
    patch entity_url(entities(:ajax_company)), params: { entity: { name: "New Name" } }
    assert_redirected_to entity_url(entities(:ajax_company))
  end

  test "should get create" do
    post entities_url, params: { entity: { name: "New Entity" } }
    assert_redirected_to entity_url(Entity.last)
  end

  test "should get destroy" do
    delete entity_url(entities(:ajax_company))
    assert_redirected_to entities_url
  end
end
