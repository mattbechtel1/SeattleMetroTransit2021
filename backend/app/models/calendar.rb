class Calendar < ApplicationRecord
    acts_as_copy_target

    has_many :trips
    has_many :calendar_dates, foreign_key: :service_id, inverse_of: :calendar

    # Returns Calendar ids (Trip#calendar_id values) with service on
    # `service_date`, per GTFS calendar.txt + calendar_dates.txt exception rules:
    #   active = (regular calendar.txt row matches AND not removed for this date)
    #            UNION (added for this date via calendar_dates.txt)
    def self.service_ids_active_on(service_date)
        date_int = service_date.strftime('%Y%m%d').to_i
        weekday_column = service_date.strftime('%A').downcase.to_sym

        removed_ids = CalendarDate.where(date: date_int, exception_type: 2).pluck(:service_id)
        added_ids = CalendarDate.where(date: date_int, exception_type: 1).pluck(:service_id)

        regular_ids = Calendar
            .where(weekday_column => true, start_date: ..date_int, end_date: date_int..)
            .where.not(id: removed_ids)
            .pluck(:id)

        (regular_ids + added_ids).uniq
    end
end
