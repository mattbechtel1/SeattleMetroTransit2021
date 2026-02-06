class RailRoute < ApplicationRecord
    acts_as_copy_target
    belongs_to :agency
    has_many :rail_trips
    has_many :rail_stoptimes, through: :rail_trips
    has_many :stations, through: :rail_stoptimes

    alias_attribute :LineCode, :id
    alias_attribute :DisplayName, :short_name


    def self.ordered_routes
        self.all.order(:route_type, :short_name)
    end

    def rail_trips_by_direction direction_id
        self.rail_trips.where(direction_id: direction_id)
    end

    def main_stations
        Station.where(id: self.stations.pluck(:stop_id).uniq)
    end

    def ordered_stations
        self.main_stations.order(:zone_id)
    end
end
