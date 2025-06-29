ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # sign_in for controller tests
    def sign_in(user = users(:admin))
      session = user.sessions.create!
      Current.session = session
      request = ActionDispatch::Request.new(Rails.application.env_config)
      cookies = request.cookie_jar
      cookies.signed[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end

    # sign_in for system tests
    def sign_in_as(user, fixture = false)
      visit new_session_url
      fill_in "email_address", with: user.email_address
      fill_in "password", with: (fixture ? "password1234567890" : user.password)
      click_button "Sign in"
      sleep 1
    end

  end
end
