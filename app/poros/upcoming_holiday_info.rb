require './app/poros/holidays_search'

class UpcomingHolidayInfo
  attr_reader :next_3_holidays

  def initialize
    @next_3_holidays = HolidaysSearch.new.holidays_information[0..2]
  end
end
