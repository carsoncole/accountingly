require "application_system_test_case"

class EntitiesTest < ApplicationSystemTestCase
  setup do
    @user = users(:admin)
    sign_in_as(@user, true)
  end

  test "visiting the entities index" do
    visit entities_url
    
    # Check that the page loads with the correct title
    assert_selector "h1", text: "Entities"
    
    # Check that the "New Entity" button is present
    assert_selector "a", text: "New Entity"
  end

  test "should create entity" do
    visit entities_url
    click_on "New Entity"
    
    # Check that we're on the new entity form
    assert_selector "h1", text: "New Entity"
    
    # Fill in the entity form
    fill_in "Name", with: "Test Company"
    
    # Submit the form
    click_on "Create Entity"
    
    # Should be redirected to the entity show page with success message
    assert_text "Entity was successfully created"
    
    # Should show the entity name
    assert_text "Test Company"
  end

  test "should not create entity with invalid data" do
    visit entities_url
    click_on "New Entity"
    
    # Try to submit without a name
    click_on "Create Entity"
    
    # Should stay on the form page with errors
    assert_selector "h1", text: "New Entity"
    assert_text "Name can't be blank"
  end

  #FIXME: This test is failing
  test "should edit entity" do
    # Create an entity first
    entity = Entity.create!(name: "Original Name")
    AdministratorAccess.create!(user_id: @user.id, entity_id: entity.id, type: "AdministratorAccess")
    visit entities_url
    
    # Find and click the edit link for the entity
    within("div.entity", text: "Original Name") do
      edit_link = find("a", text: "Edit")
      edit_link.click
    end
    
    # Check that we're on the edit form
    assert_selector "h1", text: "Edit Entity"
    
    # Update the entity name
    fill_in "Name", with: "Updated Name"
    
    # Submit the form
    click_on "Update Entity"
    
    # Should be redirected to the entity show page with success message
    assert_text "Entity was successfully updated"
    
    # Should show the updated entity name
    assert_text "Updated Name"
  end

  test "should not edit entity with invalid data" do
    # Create an entity first
    entity = Entity.create!(name: "Original Name")
    AdministratorAccess.create!(user_id: @user.id, entity_id: entity.id)
    
    visit entities_url
    
    # Find and click the edit link for the entity
    within("div.entity", text: "Original Name") do
      click_link "Edit"
    end
    
    # Clear the name field
    fill_in "entity_name", with: ""
    
    # Submit the form
    click_on "Update Entity"
    
    # Should stay on the form page with errors
    assert_selector "h1", text: "Edit Entity"
    assert_text "Name can't be blank"
  end

  test "should archive entity" do
    # Create an entity first
    entity = Entity.create!(name: "Entity to Archive")
    AdministratorAccess.create!(user_id: @user.id, entity_id: entity.id)
    
    visit entities_url
    
    # Find and click the archive button for the entity
    within("div.entity", text: "Entity to Archive") do
      click_button "Archive"
    end
    accept_confirm

    # Should be redirected to entities index with success message
    assert_text "Entity was successfully archived"
    
    # The entity should no longer be visible in the list
    assert_no_text "Entity to Archive"
  end

  test "should show entity details" do
    # Create an entity first
    entity = Entity.create!(name: "Test Entity")
    AdministratorAccess.create!(user_id: @user.id, entity_id: entity.id)
    
    visit entities_url
    
    # Click on the entity name to view details
    click_on "Test Entity"
    
    # Should be redirected to the entity's transactions page
    assert_current_path entity_path(entity)
  end

  test "should display empty state when no entities exist" do
    # Ensure no entities exist for this user
    Entity.joins(:accesses).where(accesses: { user_id: @user.id }).update_all(is_archived: true)
    
    visit entities_url
    
    # Should show empty state message
    assert_text "No entities found"
    assert_text "Get started by creating your first entity"
  end

  test "should cancel entity creation" do
    visit entities_url
    click_on "New Entity"
    
    # Click cancel button
    click_on "Cancel"
    
    # Should be redirected back to entities index
    assert_current_path entities_path
    assert_selector "h1", text: "Entities"
  end

  test "should cancel entity editing" do
    # Create an entity first
    entity = Entity.create!(name: "Original Name")
    AdministratorAccess.create!(user_id: @user.id, entity_id: entity.id)
    
    visit entities_url
    
    # Find and click the edit link for the entity
    within("div.entity", text: "Original Name") do
      click_on "Edit"
    end
    
    # Click cancel button
    click_on "Cancel"
    
    # Should be redirected back to entities index
    assert_current_path entities_path
    assert_selector "h1", text: "Entities"
  end
end 