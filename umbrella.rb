require "open-uri"
require "json"
#Ask where they're at
p "Can't tell you the weather until you tell me where you are..."
user_location = gets.chomp
p "So you want the weather for #{user_location} FINE."

#Google maps API call
gmaps_key = ENV.fetch("GMAPS_KEY")
gmaps_api = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location}&key=#{gmaps_key}"

raw_response = URI.open(gmaps_api).read
parse_response = JSON.parse(raw_response)

results_array = parse_response.fetch("results")

first_result_hash = results_array.at(0)

geometry_hash = first_result_hash.fetch("geometry")

location_hash = geometry_hash.fetch("location")

latitude = location_hash.fetch("lat")

longitude = location_hash.fetch("lng")

p "No one cares what you call that place. Its actually called #{latitude}, #{longitude}"

#Pirate Weather API call 
wx_key = ENV.fetch("PIRATE_WEATHER_KEY")
pwx_api = "https://api.pirateweather.net/forecast/#{wx_key}/#{latitude},#{longitude}"
wx_raw_response = URI.open(pwx_api).read 
parse_wx_response = JSON.parse(wx_raw_response)

current_wx = parse_wx_response.fetch("currently")
current_temp = current_wx.fetch("temperature")

puts "It is currently #{current_temp}°F."

minute_wx = parse_wx_response.fetch("minutely", false)

if minute_wx
  hour_wx = minute_wx.fetch("summary")

  puts "You're stuck with weather that can best be described as '#{hour_wx}' for the next hour. Deal with it."
end

hourly_hash = parse_wx_response.fetch("hourly")

hourly_data = hourly_hash.fetch("data")

next_twelve_hours = hourly_data[1..12]

rain_threshold = 0.10

any_precipitation = false

next_twelve_hours.each do |hour_hash|

  precip_prob = hour_hash.fetch("precipProbability")

  if precip_prob > rain_threshold
    any_precipitation = true

    precip_time = Time.at(hour_hash.fetch("time"))

    seconds_from_now = precip_time - Time.now

    hours_from_now = seconds_from_now / 60 / 60

    puts "In #{hours_from_now.round} hours, there is a #{(precip_prob * 100).round}% chance of precipitation. Cheers!"
  end
end

if any_precipitation == true
  puts "You might want to take an umbrella! Or don't and get soaked 🤷"
else
  puts "Its not going to rain, but you should still probably take an umbrella. I'm new at coding so this could be wrong."
end
