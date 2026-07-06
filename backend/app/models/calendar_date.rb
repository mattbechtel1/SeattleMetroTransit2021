class CalendarDate < ApplicationRecord
    acts_as_copy_target

    belongs_to :calendar, foreign_key: :service_id, optional: true
end
