class FilterRulesController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def create
        @rule = FilterRule.new(rule_params.except(:filter_condition))
        @rule.filter_condition = rule_params[:filter_condition].to_json
        if @rule.save
        render json: { message: "Rule created successfully", data: @rule }, status: :created
        else
        render json: { errors: @rule.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        rule = FilterRule.find(params[:id])
        rule.destroy
        render json: { message: "Deleted Successfully"}
    end
    
    def get_suitable_query
        product = ES_CLIENT.get(index: 'products',id: params[:id])["_source"]
        response=ES_CLIENT.search(
            index:"filter_rules_index",
            body:{
                query:{
                    percolate:{
                        field: "query" ,
                        document: product
                    }
                }
            }
        )
        rules = response["hits"]["hits"].map do |rule|
                {
                    filter_name: rule["_source"]["filter_name"], 
                    filter_condition: rule["_source"]["query"]["bool"]["must"]
                }
                end
        render json: rules
    end
    def index
        @rules=FilterRule.all
        render json: {
        count: @rules.count,
        rules: @rules.map do |rule|
            {
                id: rule.id,
                name: rule.filter_name,
                condition: rule.filter_condition
            }
        end
        }
    end
    def create_index
        index_name = "filter_rules_index"
        return if ES_CLIENT.indices.exists?(index: index_name)
        ES_CLIENT.indices.create(
            index: index_name,
            body:{
                mappings:{
                    properties:{
                        query:{type: "percolator" } ,
                        productname:{type: "text" } ,
                        category:{type: "keyword" } ,
                        subcategory:{type: "keyword" } ,
                        price:{type: "float" }
                    }
                }
            }
        )
        render json: { message: "Index created successfully" }, status: :ok
    end
    def fetch_all_percolator_queries
        response = ES_CLIENT.search(
            index: "filter_rules_index",
            body:{
                query:{
                    match_all: {}
                }
            }
        )
        rules = response["hits"]["hits"].map do |rule|
                {
                    id: rule["_id"],
                    filter_name: rule["_source"]["filter_name"], 
                    filter_condition: rule["_source"]["query"]["bool"]["must"]
                }
                    
        end
        render json: rules
    end

    def import
        FilterRule.importing
        render json: { status: "success"}
    end
    
    private

    def rule_params
        params.require(:filter_rule).permit(:filter_name, filter_condition:{})
    end
end
