class UserSerializer
    def initialize(obj)
        @user = obj
    end

    def to_serialized_json
        format = { 
            include: {
                favorites: {
                    except: [:created_at, :updated_at]
                }
            },
            only: [:email, :id]
        }
        @user.as_json(format)
    end
end