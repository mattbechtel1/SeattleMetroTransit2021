class RailRoute < ApplicationRecord
    acts_as_copy_target
    belongs_to :agency

    alias_attribute :LineCode, :id
    alias_attribute :DisplayName, :short_name


    def self.ordered_routes
        self.all.order(:route_type, :short_name)
    end
end
