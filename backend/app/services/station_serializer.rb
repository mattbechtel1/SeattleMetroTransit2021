class StationSerializer
    def initialize(obj)
        @station = obj
    end

    def stoptime_data stoptime
        {
            "DestinationName": stoptime.headsign,
            "Min": stoptime.minutes_to_train,
            "Line": stoptime.line_code
        }
    end

    def formatted_stoptimes
        @station.train_predictions.map {
            |stoptime| self.stoptime_data stoptime
        }
    end

    def station_trains
        {
            "Trains": self.formatted_stoptimes
        }
    end

    def to_serialized_json
        self.station_trains.to_json
    end
end