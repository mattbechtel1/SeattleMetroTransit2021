class StopSerializer
    def initialize(obj)
        @stop = obj
    end

    def to_serialized_json
        format = {
            include: {
                Predictions: {
                    methods: [:TripID, :Minutes, :DirectionText, :DirectionNum, :RouteID],
                    only: :id
                }
            },
            only: []
        }
        @stop.to_json(format)
    end
end