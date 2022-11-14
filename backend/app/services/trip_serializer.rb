class TripSerializer
    def initialize(obj)
        @trip = obj
    end

    def to_serialized_json
        format = {
            methods: [:TripDirectionText, :TripHeadsign],
            include: {
                StopTimes: {
                    methods: [:StopID, :StopName]
                }
            }
        }
        @trip.to_json(format)
    end
end