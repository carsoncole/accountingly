class Statement
  
  PERIODS = [ 'Custom', 'Monthly', 'Quarterly', 'Yearly' ]
  
  def initialize(entity,from_date,to_date=Date.today)
    @entity = entity
    @from_date = from_date
    @to_date = to_date
  end
  
end
