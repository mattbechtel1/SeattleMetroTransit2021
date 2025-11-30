class Station < ApplicationRecord
    acts_as_copy_target
    belongs_to :station, optional: true
    has_many :rail_stoptimes
    alias_attribute :Code, :id
    alias_attribute :Name, :name

    def self.ordered_stations
        self.all.where.not(description: nil).where(stop_id: nil).order(:name)
    end

    def train_predictions
        self.rail_stoptimes.trains_next_hour
    end
end
