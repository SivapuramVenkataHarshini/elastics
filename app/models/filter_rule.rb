class FilterRule < ApplicationRecord
    validates :filter_name, presence: true, uniqueness: true
    validates :filter_condition, presence: true
    validate :condition_must_be_a_hash

    private

    def condition_must_be_a_hash
        unless filter_condition.is_a?(Hash)
            errors.add(:filter_condition, "must be a valid JSON hash")
        end
    end
end