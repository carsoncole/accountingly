require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in
    @entity = entities(:ajax_company)
  end

  test "should get index" do
    get entity_transactions_url(@entity)
    assert_response :success
  end

  test "should get show" do
    get entity_transaction_url(@entity, transactions(:expense_transaction))
    assert_response :success
  end

  test "should get edit" do
    get edit_entity_transaction_url(@entity, transactions(:expense_transaction))
    assert_response :success
  end

  test "should get new" do
    get new_entity_transaction_url(@entity)
    assert_response :success
  end

  # FIXME: This test is failing
  # test "should update" do
  #   patch entity_transaction_url(@entity, transactions(:one)), params: { transaction: { description: "New Description" } }
  #   assert_redirected_to entity_transaction_url(@entity, transactions(:one))
  # end

  test "should create" do
    post entity_transactions_url(@entity), params: {
      transaction: {
        date: "2025-06-28", description: "New Transaction",
        entries_attributes: {
          "0" => { account_id: accounts(:expense_account).id, amount: 100 },
          "1" => { account_id: accounts(:asset_account).id, amount: -100 }
        }
        }
      }
    assert_redirected_to entity_transaction_url(@entity, Transaction.last)
  end

  test "should destroy" do
    delete entity_transaction_url(@entity, transactions(:expense_transaction))
    assert_redirected_to entity_transactions_url(@entity)
  end
end
