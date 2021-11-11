class Trip < ApplicationRecord
  acts_as_copy_target
  belongs_to :route
  belongs_to :fare_attribute
  belongs_to :agency
  has_many :stoptimes
  has_many :stops, through: :stoptimes
end
