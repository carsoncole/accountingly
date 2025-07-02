require "test_helper"

class EntryTest < ActiveSupport::TestCase
  #FIXME: This test is failing
  # test "previous entry" do
  #   assert_equal entries(:expense_entry), entries(:single_entry).previous_entry
  # end

  #FIXME: This test is failing
  # test "should have a balance" do
  #   entry = Entry.create(transaction_id: transactions(:three).id, account_id: accounts(:expense_account).id, amount: 10)
  #   assert_equal 45.5, entry.reload.balance
  # end

  test "should not allow entry in archived period" do
    entry = Entry.build(transaction_id: transactions(:four).id, account: accounts(:expense_account), amount: 10)
    assert_not entry.valid?
    assert_equal "Can not add or edit entries in an archived period", entry.errors.full_messages.first
  end

  test "reprocess account balance" do
    Entry.reprocess_account_balances(accounts(:expense_account).id, Date.new(2020, 1, 1))
    assert_equal 100, entries(:single_entry).balance
  end

  # test "reprocess account balance with new entry" do
  #   transaction = Transaction.create(entity: entities(:ajax_company), date: Date.new(2025, 6, 27), description: "Test")
  #   entry = Entry.create(transaction_id: transaction.id, account_id: accounts(:expense_account).id, amount: 10)
  #   assert_equal 45.5, entry.reload.balance
  # end
end
