require "test_helper"

class EntriesControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in
    @entity = entities(:ajax_company)
    @account = accounts(:expense_account)
  end

  test "should get index" do
    get entity_account_entries_url(@entity, @account)
    assert_response :success
  end

end
