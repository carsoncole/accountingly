class BaseController < ApplicationController

  def set_last_use_entity!
    Current.user.set_last_use_entity!(entity)
  end

  def entity
    @entity ||= if Current.user
      if params[:entity_id]
        Entity.find(params[:entity_id])
      elsif Current.user.last_use_entity_id
        Entity.find(current_user.last_use_entity_id)
      else
        nil
      end
    end
  end

  def administrator?
    Current.user.accesses.select { |a| a.class == AdministratorAccess }.empty? ? false : true
  end

  def writer?
    Current.user.accesses.select { |a| a.class == WriteAccess }.empty? ? false : true
  end

  def reader?
    Current.user.accesses.select { |a| a.class == ReadAccess }.empty? ? false : true
  end
end
