class Account < ApplicationRecord

  TYPES = [
      'Asset',
      'Liability',
      'Income',
      'Expense',
      'Equity'
    ]

  has_many :entries
  belongs_to :entity
  validates :name, :entity_id, :presence => true
  validates :name, :length => { :maximum => 30 }
  validates_numericality_of :rank

  def balance
    entries.sum(:amount) * addition_or_subtraction
  end

  def addition_or_subtraction
    case type
    when 'Asset', 'Expense'
      1
    when 'Liability', 'Income', 'Equity'
      -1
    else
      1
    end
  end

end
