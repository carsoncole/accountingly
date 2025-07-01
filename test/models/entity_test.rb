require "test_helper"

class EntityTest < ActiveSupport::TestCase
  test "should be active" do
    assert_not entities(:ajax_company).is_archived?
    assert_equal 3, Entity.active.count
  end

  test "should be archived" do
    assert entities(:archived_company).is_archived?
  end

  test "#add_basic_set_of_accounts!" do
    entity = Entity.new(name: "Test Entity")
    entity.save!
    assert_equal 5, entity.accounts.count
  end

  test "#add_basic_set_of_accounts! adds retained earnings account" do
    entity = Entity.new(name: "Test Entity")
    entity.save!
    assert entity.reload.retained_earnings_account.present?
  end

  
end
