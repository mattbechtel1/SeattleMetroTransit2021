class User < ApplicationRecord
    has_secure_password
    validates :email, uniqueness: {case_sensitive: false}

    def favorites
        Favorite.where('user_id = ?', self.id)
    end
end
