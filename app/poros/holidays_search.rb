require './app/services/holidays_service'
require './app/poros/holidays'

class HolidaysSearch 
  def holidays_information 
    service.upcoming_holidays.map do |data| 
      Holidays.new(data)
    end
  end

  def service 
    HolidaysService.new
  end
end