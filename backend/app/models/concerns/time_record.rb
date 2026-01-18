module TimeRecord
    extend ActiveSupport::Concern

    def real_departure_time
        converted_time = self.departure_time
        if self.departure_time[0].to_i == 2 && self.departure_time[1].to_i > 3
            converted_time[0] = "0"
            converted_time[1] = (self.departure_time[1].to_i - 4).to_s
        end
        converted_time
    end
end