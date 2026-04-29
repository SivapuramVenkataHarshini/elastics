class Product1 < ApplicationRecord
  has_many :cart_items
  validate :check_presence
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  after_commit :index_to_elasticsearch, on: [:create]
  def check_presence
    if payload.blank?
      errors.add(:payload, "can't be blank")
      return
    end
    field_data = DynamicField.pluck(:field_name, :field_type).to_h
    payload.each do |key, value|
      unless field_data.key?(key)
        errors.add(:payload, "unknown field: #{key}")
        next
      end
      unless valid_type?(value, field_data[key])
        errors.add(:payload, "#{key} has invalid datatype")
      end
    end
  end

  def valid_type?(value, type)
    case type
    when "integer"
      value.is_a?(Integer)
    when "float"
      value.is_a?(Float) 
    when "boolean"
      %w[true false].include?(value.to_s.downcase)
    when "string"
      value.is_a?(String)
    else
      false
    end
  end

  def index_to_elasticsearch
    ES_CLIENT.index(
      index: 'products1',
      id: self.id,
      body: self.payload
    )
  end
end