class Route < ApplicationRecord
  acts_as_copy_target
  belongs_to :agency
  has_many :trips
  has_many :route_fares
  has_many :fares, through: :route_fares, source: :fare_attribute

  alias_attribute :LineDescription, :description
  alias_attribute :RouteID, :short_name

  def self.ordered_routes
    self.all.order(:short_name)
  end
end
