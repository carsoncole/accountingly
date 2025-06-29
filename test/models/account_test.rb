require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "should have a balance" do
    assert_equal 35.5, accounts(:expense_account).balance
  end

end
