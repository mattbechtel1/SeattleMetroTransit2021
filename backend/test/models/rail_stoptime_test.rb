require "test_helper"

class RailStoptimeTest < ActiveSupport::TestCase
  test "trains_next_hour, called through Station#train_predictions, only returns that station's own rail_stoptimes" do
    calendar = RailCalendar.create!(
      id: "TEST_TRAINS_NEXT_HOUR",
      monday: true, tuesday: true, wednesday: true, thursday: true,
      friday: true, saturday: true, sunday: true,
      start_date: 20200101, end_date: 20301231
    )

    station_a = stations(:one)
    station_b = stations(:two)
    # A non-nil stop_id different from the station's own id makes Station#train_predictions
    # take the direct self.rail_stoptimes.trains_next_hour branch rather than the platform-aggregation branch.
    station_a.update_columns(stop_id: "PARENT_STATION")
    station_b.update_columns(stop_id: "PARENT_STATION")

    trip_a = RailTrip.create!(rail_trip_id: "TEST_TRIP_A", rail_route: rail_routes(:one), rail_calendar: calendar, direction_id: 0)
    trip_b = RailTrip.create!(rail_trip_id: "TEST_TRIP_B", rail_route: rail_routes(:two), rail_calendar: calendar, direction_id: 0)

    travel_to Time.new(2026, 1, 5, 10, 0, 0) do
      departure = (Time.now + 300).strftime("%H:%M:%S")

      stoptime_a = RailStoptime.create!(rail_trip: trip_a, station: station_a, departure_time: departure, arrival_time: departure, sequence: 1)
      RailStoptime.create!(rail_trip: trip_b, station: station_b, departure_time: departure, arrival_time: departure, sequence: 1)

      predictions = station_a.train_predictions

      assert_includes predictions, stoptime_a
      assert_equal 1, predictions.size
    end
  end
end
