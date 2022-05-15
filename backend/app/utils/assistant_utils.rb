module AssistantUtils
    def day_of_week
        {
            'Sun' => 'sunday',
            'Mon' => 'monday',
            'Tue' => 'tuesday',
            'Wed' => 'wednesday',
            'Thu' => 'thursday',
            'Fri' => 'friday',
            'Sat' => 'saturday',
            'Sun' => 'sunday'
        }[Date.today().strftime('%a')]
    end

end