class RouteSerializer
    def initialize(obj)
        @route = obj
    end

    def to_serialized_json
        format = {
            methods: [:RouteID, :LineDescription]
        }
        @route.as_json(format)
    end
end