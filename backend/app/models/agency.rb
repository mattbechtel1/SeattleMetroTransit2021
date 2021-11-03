class Agency < ApplicationRecord
    acts_as_copy_target
    has_many :fares, class_name: "FareAttribute"
    has_many :routes
    has_many :trips, through: :routes
end
