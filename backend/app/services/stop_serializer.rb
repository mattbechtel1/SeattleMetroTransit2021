class StopSerializer
    def initialize(obj)
        @stop = obj
    end

    def to_serialized_json
        format = { 
            include: {
                BusPredictions: {
                    except: [:created_at, :updated_at]
                }
            },
            methods: [:StopName],
            only: [:code]
        }
        byebug
        @stop.to_json(format)
    end
end