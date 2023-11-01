class RailRoute < ApplicationRecord
    acts_as_copy_target
    belongs_to :agency
end
