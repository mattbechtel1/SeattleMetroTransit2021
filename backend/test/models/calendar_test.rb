require 'test_helper'

class CalendarTest < ActiveSupport::TestCase
  MONDAY = Date.new(2026, 1, 5)
  SATURDAY = Date.new(2026, 1, 10)
  NEXT_MONDAY = Date.new(2026, 1, 12)

  test "service_ids_active_on includes a calendar.txt weekday service on a matching day and excludes it otherwise" do
    calendar = Calendar.create!(
      monday: true, tuesday: false, wednesday: false, thursday: false,
      friday: false, saturday: false, sunday: false,
      start_date: 20260101, end_date: 20261231
    )

    assert_includes Calendar.service_ids_active_on(MONDAY), calendar.id
    refute_includes Calendar.service_ids_active_on(SATURDAY), calendar.id
  end

  test "service_ids_active_on includes a calendar_dates-only added service only on its exception date" do
    service_id = (Calendar.maximum(:id) || 0) + 1_000_000
    CalendarDate.create!(service_id: service_id, date: SATURDAY.strftime('%Y%m%d').to_i, exception_type: 1)

    assert_includes Calendar.service_ids_active_on(SATURDAY), service_id
    refute_includes Calendar.service_ids_active_on(MONDAY), service_id
  end

  test "service_ids_active_on excludes a service removed via calendar_dates exception on a specific date, but still includes it on other matching days" do
    calendar = Calendar.create!(
      monday: true, tuesday: false, wednesday: false, thursday: false,
      friday: false, saturday: false, sunday: false,
      start_date: 20260101, end_date: 20261231
    )
    CalendarDate.create!(service_id: calendar.id, date: MONDAY.strftime('%Y%m%d').to_i, exception_type: 2)

    refute_includes Calendar.service_ids_active_on(MONDAY), calendar.id
    assert_includes Calendar.service_ids_active_on(NEXT_MONDAY), calendar.id
  end
end
