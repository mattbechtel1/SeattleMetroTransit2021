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
        # GTFS zone_id is a fare zone, not a sequence. Sound Transit's shared
        # tunnel zone "DSTT" breaks ordering on the 1 & 2 Lines — use stop_sequence
        # from a representative trip instead.
        representative_trip = rail_trips
            .where(direction_id: 0)
            .left_joins(:rail_stoptimes)
            .group(:rail_trip_id)
            .order(Arel.sql('COUNT(rail_stoptimes.id) DESC'))
            .first

        return main_stations.order(:zone_id) if representative_trip.nil?

        platform_ids_in_order = representative_trip.rail_stoptimes
                                                   .order(:sequence)
                                                   .pluck(:station_id)
        parent_by_platform = Station.where(id: platform_ids_in_order)
                                    .pluck(:id, :stop_id).to_h
        ordered_main_ids = platform_ids_in_order
                             .map { |pid| parent_by_platform[pid] || pid }
                             .uniq

        stations_by_id = main_stations.where(id: ordered_main_ids).index_by(&:id)
        ordered_main_ids.map { |id| stations_by_id[id] }.compact
    end
end
