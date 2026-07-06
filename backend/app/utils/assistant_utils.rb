module AssistantUtils
    # Trips with GTFS times >= 24:00:00 belong to the previous calendar day's
    # service, so anything before 4am local time is still part of yesterday's service.
    def service_date(now = Time.zone.now)
        now.hour < 4 ? (now.to_date - 1) : now.to_date
    end
end