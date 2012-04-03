class Start < ActiveRecord::Base
  before_save :default_values

  def default_values
    self.start = 0 unless self.start
  end
end
