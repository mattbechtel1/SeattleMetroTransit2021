class TripSerializer
    def initialize(obj)
        @trip = obj
    end

    def to_serialized_json
        format = {
            methods: [:direction]
        }
        @trip.as_json(format)
    end
end