require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "should be balanced" do
    transaction = transactions(:expense_transaction)
    assert transaction.balanced?
  end

  test "should not be balanced" do
    transaction = transactions(:single_entry_transaction)
    assert_not transaction.balanced?
  end

  test "new transactions not allowed during archive period" do
    transaction = Transaction.new(entity: entities(:ajax_company), date: Date.new(2020, 6, 1), description: "Test")
    assert_not transaction.valid?
    assert_equal "Date is within an archived period.", transaction.errors.full_messages.join(", ")
  end

  test "unbalanced transactions are not allowed" do
    transaction = Transaction.new(entity: entities(:ajax_company), date: Date.new(2025, 6, 1), description: "Test")
    transaction.entries.build(account: accounts(:expense_account), amount: 100) 
    assert_not transaction.valid?
    assert_equal "Transaction is not balanced.", transaction.errors.full_messages.join(", ")
  end

  test "balanced transactions with asset accounts are allowed" do
    transaction = Transaction.new(entity: entities(:ajax_company), date: Date.new(2025, 6, 1), description: "Buying an asset")
    transaction.entries.build(account: accounts(:asset_account), amount: -10)
    transaction.entries.build(account: accounts(:asset_account), amount: 10)
    assert transaction.valid?
  end

  test "balanced transactions with expense and equity accounts are allowed" do
    transaction = Transaction.new(entity: entities(:ajax_company), date: Date.new(2025, 6, 1), description: "Sales")
    # Record the sale
    transaction.entries.build(account: accounts(:asset_account), amount: 100, description: "Cash")
    transaction.entries.build(account: accounts(:income_account), amount: 100, description: "Sales")

    # Record the cost of goods sold
    transaction.entries.build(account: accounts(:asset_account), amount: -10, description: "Inventory")
    transaction.entries.build(account: accounts(:expense_account), amount: 10, description: "Cost of goods sold")

    assert transaction.valid?
  end

  test "balanced transactions with assets and liabilities are allowed" do
    transaction = Transaction.new(entity: entities(:ajax_company), date: Date.new(2025, 6, 1), description: "Loan")
    transaction.entries.build(account: accounts(:asset_account), amount: 150.50)
    transaction.entries.build(account: accounts(:liability_account), amount: 150.50)
    assert transaction.valid?
  end

  test "transactions can not be updated during archive period" do
    transaction = transactions(:archived_transaction)
    assert_not transaction.update(date: Date.new(2025, 6, 1))
    assert_equal "Date is within an archived period.", transaction.errors.full_messages.join(", ")
  end

  test "transactions can not be destroyed during archive period" do
    transaction = transactions(:archived_transaction)
    assert_not transaction.destroy
    assert_equal "Date is within an archived period.", transaction.errors.full_messages.join(", ")
  end
end
