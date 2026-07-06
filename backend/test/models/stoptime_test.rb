require 'test_helper'

class StoptimeTest < ActiveSupport::TestCase
  test "buses_next_hour, called through Stop#bus_predictions, only returns that stop's own stoptimes" do
    calendar = Calendar.create!(
      monday: true, tuesday: true, wednesday: true, thursday: true,
      friday: true, saturday: true, sunday: true,
      start_date: 20200101, end_date: 20301231
    )

    stop_a = stops(:one)
    stop_b = stops(:two)

    trip_a = Trip.new(route_id: routes(:one).id, fare_attribute_id: fare_attributes(:one).id, calendar_id: calendar.id, direction_id: 0)
    trip_a.save!(validate: false)
    trip_b = Trip.new(route_id: routes(:two).id, fare_attribute_id: fare_attributes(:two).id, calendar_id: calendar.id, direction_id: 0)
    trip_b.save!(validate: false)

    travel_to Time.new(2026, 1, 5, 10, 0, 0) do
      departure = (Time.now + 300).strftime("%H:%M:%S")

      stoptime_a = Stoptime.create!(trip: trip_a, stop: stop_a, departure_time: departure, arrival_time: departure, sequence: 1)
      Stoptime.create!(trip: trip_b, stop: stop_b, departure_time: departure, arrival_time: departure, sequence: 1)

      predictions = stop_a.bus_predictions

      assert_includes predictions, stoptime_a
      assert_equal 1, predictions.size
    end
  end
end
