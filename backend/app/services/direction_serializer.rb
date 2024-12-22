class DirectionSerializer
    attr_reader :trip_list0, :trip_list1
    
    def initialize(trip_list0, trip_list1)
        @trip_list0 = trip_list0
        @trip_list1 = trip_list1
    end

    def develop_trips trip_list
        id_list = trip_list.pluck(:id).uniq
        Trip.get_stoptimes id_list
    end

    def to_serialized_json
        stoptimes_return0 = self.develop_trips self.trip_list0
        stoptimes_return1 = self.develop_trips self.trip_list1
        {
            Direction0: self.trip_list0.map { |trip| 
                JSON.parse(TripSerializer.new(trip, stoptimes_return0).formatted)
            }, 
            Direction1: self.trip_list1.map { |trip| 
                JSON.parse(TripSerializer.new(trip, stoptimes_return1).formatted)
            },
            Name: @trip_list0.first.route_name
        }.to_json
    end
end