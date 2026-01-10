class RailCalendar < ApplicationRecord
    acts_as_copy_target

    has_many :rail_trips
end
