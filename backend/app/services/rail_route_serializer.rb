class RailRouteSerializer
    def initialize(obj)
        @route = obj
    end

    def to_serialized_json
        format = {
            methods: [:LineCode, :DisplayName]
        }
        @route.as_json(format)
    end
end