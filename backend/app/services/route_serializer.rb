class RouteSerializer
    def initialize(obj)
        @route = obj
    end

    def to_serialized_json
        format = {
            # include: {
            #     Predictions: {
            #         methods: [:TripID, :Minutes, :DirectionText, :DirectionNum, :RouteID],
            #         only: :id
            #     }
            # },
            methods: [:RouteID, :LineDescription]
        }
        @route.as_json(format)
    end
end