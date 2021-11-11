class Stoptime < ApplicationRecord
  acts_as_copy_target
  belongs_to :trip
  belongs_to :stop
end
