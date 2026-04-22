class DynamicField < ApplicationRecord
    after_commit :update_mapping, on: [:create]
    def map_es_type(field_type)
        case field_type.downcase
        when "string"
            "text"
        when "integer"
            "integer"
        when "float"
            "float"
        when "boolean"
            "boolean"
        when "date"
            "date"
        else
            "text"
        end
    end
    def update_mapping
        ES_CLIENT.indices.put_mapping(
            index: "products",
            body:{
                properties: {
                    field_name => {
                        type: map_es_type(field_type)
                    } 
                }
            }
        )
    end
    
end
