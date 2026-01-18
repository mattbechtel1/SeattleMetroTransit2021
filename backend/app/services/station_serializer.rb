class StationSerializer
    def initialize(obj)
        @station = obj
    end

    def to_serialized_json
        format = {
            include: {
                Trains: {
                    methods: [:DestinationName, :Line, :Min]
                }
            }
        }
        @station.to_json(format)
    end
end