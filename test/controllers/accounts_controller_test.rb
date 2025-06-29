require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in
    @account = accounts(:expense_account)
  end

  test "should get index" do
    get entity_accounts_url(entities(:ajax_company))
    assert_response :success
  end

  test "should get new" do
    get new_entity_account_url(entities(:ajax_company))
    assert_response :success
  end

  test "should create account" do
    assert_difference("Account.count") do
      post entity_accounts_url(entities(:ajax_company)), params: { account: { name: "Telephone Co", type: "Expense" } }
    end

    assert_redirected_to entity_accounts_url(entities(:ajax_company))
  end

  test "should show account" do
    get entity_account_url(entities(:ajax_company), @account)
    assert_response :success
  end

  test "should get edit" do
    get edit_entity_account_url(entities(:ajax_company), @account)
    assert_response :success
  end

  test "should update account" do
    patch entity_account_url(entities(:ajax_company), @account), params: { account: { name: @account.name, note: @account.note, rank: @account.rank, type: @account.type } }
    assert_redirected_to entity_accounts_url(entities(:ajax_company))
  end

  test "should destroy account" do
    assert_difference("Account.count", -1) do
      delete entity_account_url(entities(:ajax_company), @account)
    end

    assert_redirected_to entity_accounts_url(entities(:ajax_company))
  end
end
