class Holidays 
  attr_reader :holiday_name, :date

  def initialize(data)
    @holiday_name = data[:name]
    @date = data[:date]
  end
end