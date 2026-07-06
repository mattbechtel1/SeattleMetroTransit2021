class RailCalendarDate < ApplicationRecord
    acts_as_copy_target

    belongs_to :rail_calendar, foreign_key: :service_id, optional: true
end
