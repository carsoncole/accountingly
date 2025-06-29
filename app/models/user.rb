class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  has_many :accesses, :dependent => :destroy
  has_many :entities, :through => :accesses

  def name
    email_address
  end

  def permission(entity)
    return Access.where(:user_id => self.id, :entity_id => entity.id).first.permission
  end

  def super_administrator?(entity)
    if Access.where(:user_id => self.id).where(:entity_id => entity.id).where(type: 'Super Administrator').first
      return true
    else
      return false
    end
  end

  def administrator?(entity)
    if Access.where(:user_id => self.id).where(:entity_id => entity.id).where(type: 'AdministratorAccess').first
      return true
    else
      return false
    end
  end

  def administrator_or_higher?(entity)
    permission = Assignment.where(:user_id => self.id).where(:entity_id => entity.id).first.permission
    if permission == 'Administrator' || permission == 'Super Administrator'
      return true
    else
      return false
    end
  end

  def editor?(entity)
    if Assignment.where(:user_id => self.id).where( :entity_id => entity.id).first.permission == 'Editor'
      return true
    else
      return false
    end
  end

  def editor_or_higher?(entity)
    permission = Assignment.where(:user_id => self.id).where(:entity_id => entity.id).first.permission
    if permission == 'Editor' || administrator_or_higher?(entity)
      return true
    else
      return false
    end
  end


  def reader?(entity)
    if Assignment.where(:user_id => self.id).where(:entity_id => entity.id).first.permission == 'Reader'
      return true
    else
      return false
    end
  end

  def reader_or_higher?(entity)
    permission = Assignment.where(:user_id => self.id).where(:entity_id => entity.id).first.permission
    if permission == 'Reader' || editor_or_higher?(entity)
      return true
    else
      return false
    end
  end

  def author?(entity)
    if Assignment.where(:user_id => self.id).where( :entity_id => entity.id).first.permission == 'Author'
      return true
    else
      return false
    end
  end

  def author_or_higher?(entity)
    permission = Assignment.where(:user_id => self.id).where(:entity_id => entity.id).first.permission
    if permission == 'Author' || editor_or_higher?(entity)
      return true
    else
      return false
    end
  end

  def set_last_use_entity!(entity=nil)
    return unless entity
    update_attribute(:last_use_entity_id, entity.id)
  end

  def transactions(entity)
    if reader_or_higher?(entity)
      transactions = Transaction.where(:entity_id => entity)
    elsif author?(entity)
      transactions = Transaction.where(:entity_id => entity).where(:user_id => self.id)
    end
    return transactions
  end


end
