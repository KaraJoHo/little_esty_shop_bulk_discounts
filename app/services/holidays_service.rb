require 'httparty'

class HolidaysService
  def get_url(url)
    response = HTTParty.get(url)
    parsed = JSON.parse(response.body, symbolize_names: true)
  end

  def upcoming_holidays 
    get_url("https://date.nager.at/api/v3/NextPublicHolidays/US")
  end
end