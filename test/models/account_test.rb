require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "should have a balance" do
    assert_equal 10, accounts(:expense_account).balance
  end
end
