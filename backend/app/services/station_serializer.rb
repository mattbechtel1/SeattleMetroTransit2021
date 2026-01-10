class StationSerializer
    def initialize(obj)
        @station = obj
    end

    def to_serialized_json
        format = {
            include: {
                Trains: {
                    only: [:arrival_time, :departure_time, :rail_trip_id]
                }
            }
        }
        @station.to_json(format)
    end
end