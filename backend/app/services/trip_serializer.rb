class TripSerializer
    def initialize(obj, all_stoptimes)
        @trip = obj
        @trip_id = obj.id
        @stoptimes = all_stoptimes
    end

    def trip_data 
        {
            "TripDirectionText": @trip.directional_text,
            "TripHeadsign": @trip.headsign,
            "StopTimes": self.formatted_stoptimes,
            "RouteID": @trip.route_name,
        }
    end

    
    def matching_stoptimes
        @stoptimes.where(trip_id: @trip_id)
    end
        
    def stoptime_data stoptime
        {
            "StopID": stoptime['stop_id'],
            "StopName": stoptime['stop_name']
        }
    end
        
    def formatted_stoptimes
        self.matching_stoptimes.map {
            |stoptime| self.stoptime_data stoptime
        }
    end

    def formatted
        self.trip_data.to_json
    end

    def to_serialized_json
        # Returns a formatted trip object
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
