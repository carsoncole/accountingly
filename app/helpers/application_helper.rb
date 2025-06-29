module ApplicationHelper
  include Pagy::Frontend
  def nice_date(date=Date.today)
    if date == Date.today
        "Today"
    elsif date.year ==  Date.today.year
        date.strftime("%b %d")
    else
        date.strftime("%b %d, '%y")
    end
  end

  def format_date_long(date=Date.today)
    date.strftime("%B %d, %Y")
  end
  
  def format_date_short(date=Date.today)
    date.strftime("%b-%d-%y")
  end
  
  def nice_datetime(date)
    date.strftime("%B %d, %Y %I:%M%p %Z")
  end
  
  def nice_datetime_compact(date)
    date.strftime("%m/%d/%y %R")
  end

  def entity
    if params[:entity_id]
        @entity = Entity.find(params[:entity_id])
    end
      @entity
    end    
end
