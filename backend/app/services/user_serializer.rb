class UserSerializer
    def initialize(obj)
        @user = obj
    end

    def to_serialized_json
        format = { 
            only: [:email, :id]
        }
        @user.to_json(format)
    end
end