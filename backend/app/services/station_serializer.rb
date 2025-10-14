class StationSerializer
    def initialize(obj)
        @station = obj
    end

    def to_serialized_json
        format = {
            methods: [:Name, :Code], 
        }
        @station.as_json(format)
    end
end


