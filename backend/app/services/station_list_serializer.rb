class StationListSerializer
    def initialize(obj)
        @station_list = obj
    end

    def to_serialized_json
        format = {
            methods: [:Name, :Code], 
        }
        @station_list.as_json(format)
    end
end