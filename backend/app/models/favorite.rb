class Favorite < ApplicationRecord
  belongs_to :user
  validates :lookup, uniqueness: { scope: :user }
end
