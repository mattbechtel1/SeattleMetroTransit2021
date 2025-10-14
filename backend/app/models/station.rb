class Station < ApplicationRecord
    acts_as_copy_target
    belongs_to :station, optional: true
    alias_attribute :Code, :id
    alias_attribute :Name, :name

    def self.ordered_stations
        self.all.where.not(description: nil).where(stop_id: nil).order(:name)
    end
end
