class Access < ApplicationRecord
  belongs_to :user
  belongs_to :entity

  validates :user_id, presence: { message: "email is not recognized" }, uniqueness: { scope: [ :entity_id ], message: "already granted access" }

  before_validation :find_user!

  attr_accessor :email_address

  def name
    "undefined"
  end

  private

  def find_user!
    user = User.find_by(email_address: email_address)
    if user
      self.user_id = user.id
    end
  end
end
