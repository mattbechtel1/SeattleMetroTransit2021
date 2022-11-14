class DirectionSerializer
    def initialize(trip_list0, trip_list1)
        @trip_list0 = trip_list0
        @trip_list1 = trip_list1
    end

    def to_serialized_json
        {
            Direction0: @trip_list0.map { |trip| 
                JSON.parse(TripSerializer.new(trip).to_serialized_json)
            }, 
            Direction1: @trip_list1.map { |trip| 
                JSON.parse(TripSerializer.new(trip).to_serialized_json)
            },
            Name: @trip_list0.first.route_name
        }.to_json
    end
end