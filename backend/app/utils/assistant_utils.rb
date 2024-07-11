module AssistantUtils
    WEEK_MAP = {
        'Sun' => 'sunday',
        'Mon' => 'monday',
        'Tue' => 'tuesday',
        'Wed' => 'wednesday',
        'Thu' => 'thursday',
        'Fri' => 'friday',
        'Sat' => 'saturday',
    }

    def day_of_week
        WEEK_MAP[Date.today.strftime('%a')]
    end

    def adj_day_of_week
        if Time.now.hour < 4
            WEEK_MAP[Date.yesterday.strftime('%a')]
        else
            day_of_week
        end
    end

end