class Station < ApplicationRecord
    acts_as_copy_target
    belongs_to :main_station, class_name: "Station", foreign_key: :stop_id
    has_many :platforms, class_name: "Station", foreign_key: :stop_id
    has_many :rail_stoptimes
    alias_attribute :Code, :id
    alias_attribute :Name, :name

    def self.ordered_stations
        self.all.where.not(description: nil).where(stop_id: nil).order(:name)
    end

    def train_predictions
        if self.stop_id.nil? || self.stop_id === self.id
            # Use platforms
            RailStoptime.where(station_id: self.platforms.pluck(:id)).trains_next_hour
        else
            self.rail_stoptimes.trains_next_hour
        end
    end

    def station
        self.main_station || self
    end
end
