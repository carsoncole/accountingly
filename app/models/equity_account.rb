class EquityAccount < Account

  before_save :disallow_retained_earnings_act_name_change, :if => Proc.new { |a| !a.new_record? && a.name_changed? }


  def disallow_retained_earnings_act_name_change
    self.name = self.name_was
  end

  def addition_or_subtraction
    -1
  end

end
