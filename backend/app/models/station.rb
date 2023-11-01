class Station < ApplicationRecord
    acts_as_copy_target
    belongs_to :station, optional: true  
end
