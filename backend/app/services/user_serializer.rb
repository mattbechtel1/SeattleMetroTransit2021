class UserSerializer
    def initialize(obj)
        @user = obj
    end

    def to_serialized_json
        format = { 
            include: {
                favorites: {
                    only: [:url, :description]
                }
            },
            only: [:email, :id]
        }
        @user.to_json(format)
    end
end