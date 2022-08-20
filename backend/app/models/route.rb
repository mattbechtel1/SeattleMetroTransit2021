class Route < ApplicationRecord
  acts_as_copy_target
  belongs_to :agency
  has_many :trips
  has_many :route_fares
  has_many :fares, through: :route_fares, source: :fare_attribute

  alias_attribute :LineDescription, :description

  def RouteID
    id.to_s
  end

end
