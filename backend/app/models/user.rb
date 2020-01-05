class User < ApplicationRecord
    has_secure_password

    def favorites
        Favorite.where('user_id = ?', self.id)
    end
end
