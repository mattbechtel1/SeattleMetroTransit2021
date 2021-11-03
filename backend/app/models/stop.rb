class Stop < ApplicationRecord
  acts_as_copy_target
  belongs_to :stop, optional: true
end
