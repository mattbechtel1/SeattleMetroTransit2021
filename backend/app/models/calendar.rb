class Calendar < ApplicationRecord
    acts_as_copy_target

    has_many :trips
end
