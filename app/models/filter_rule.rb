class FilterRule < ApplicationRecord
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    validates :filter_name, presence: true
    # validate :condition_must_be_a_hash
    # attribute :filter_condition2, :json
    # serialize :filter_condition2, coder: JSON , type: Hash

    after_commit :add_to_percolate ,on: [:create]
    after_destroy :delete_from_percolate ,on: [:destroy]

    def add_to_percolate
        condition = FilterRule.parse_condition(self.filter_condition)
        query = FilterRule.build_query(condition)
        ES_CLIENT.index(
            index: "filter_rules_index",
            id: self.id,
            body: query.merge(
                filter_name: self.filter_name
            )
        )
    end

    def delete_from_percolate
        ES_CLIENT.delete(
            index: "filter_rules_index",
            id: self.id
        )
    end

    def self.importing
        body = []
        FilterRule.find_each do |rule|
            condition = FilterRule.parse_condition(rule.filter_condition) 
            query_body =  FilterRule.build_query(condition)
            body << { index: { _index: "filter_rules_index" , _id: rule.id } }
            body << query_body.merge(
                    filter_name: rule.filter_name
                )
        end
        ES_CLIENT.bulk(body: body) if body.any?
    end

    def self.parse_condition(condition)
        return {} if condition.blank?
        JSON.parse(condition)
    end
    
    def self.build_query(conditions)
        queries=[]
        conditions.each do |field,value|
            case value
            when Hash 
                if value.keys.any? { |k| %w[lt lte gt gte].include?(k) }
                    queries << { range: { field => value } }
                else
                    queries << { term: { field => value } }
                end
            when Array
                queries << { terms: { field => value } }
            else
                queries << { term: { field => value } }
            end
        end
        {
            query:{
                bool:{
                    must: queries
                }
            }
        }
    end
    # private

    # def condition_must_be_a_hash
    #     unless filter_condition.is_a?(Hash)
    #         errors.add(:filter_condition, "must be a valid JSON hash")
    #     end
    # end

end