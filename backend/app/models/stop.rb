class Stop < ApplicationRecord
  acts_as_copy_target
  belongs_to :stop, optional: true
  has_many :stoptimes
  has_many :trips, through: :stoptimes
  has_many :routes, through: :trips
end
