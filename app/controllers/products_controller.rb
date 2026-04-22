class ProductsController < ApplicationController
    skip_before_action :verify_authenticity_token
    def create
        data=Product.create(user_params)       
        render json: data
    end

    def index
        render json: Product.all
    end

    def update
        product = Product.find(params[:id])
        if product.update(user_params)
            WriteProductToFileJob.perform_later(user_params)
            render json: product
        else
            render json: product.errors, status: :unprocessable_entity
        end

    end

    def get_single_product
        response = ES_CLIENT.get(index: 'products',id: params[:id])
        render json:{
            product: response["_source"]
        }
    end

    def destroy
        product = Product.find(params[:id])
        if product.destroy
            render json: { message: "Deleted successfully" }
        else
            render json: { error: "Deletion failed" }
        end
    end
       
    def search
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 5).to_i
        allowed_sort_fields = ["price", "productname"]
        sort_by = params[:sort_by].presence_in(allowed_sort_fields)
        sort_order = params[:sort_order].presence_in(["asc", "desc"]) || "asc"       
        category_scope = params[:category]
        if category_scope.blank? && params[:subcategory].present?
            cat_resp = ES_CLIENT.search(index: 'products', body: {
                size: 1,
                query: { match: { "subcategory": params[:subcategory] } }
            })
            category_scope = cat_resp.dig("hits", "hits", 0, "_source", "category")
        end
        must_conditions = []
        must_conditions << { match: { "category": category_scope } } if category_scope.present?
        if params[:q].present?
            must_conditions << { multi_match: { query: params[:q], fields: ["productname", "subcategory"] } }
        end
        post_filters = []
        if params[:subcategory].present?
            post_filters << { match: { "subcategory": params[:subcategory] } }
        end
        if params[:min_price].present? || params[:max_price].present?
            post_filters << {
                range: {
                    price: {
                        gte: params[:min_price].present? ? params[:min_price].to_f : 0,
                        lte: params[:max_price].present? ? params[:max_price].to_f : 999_999
                    }
                }
            }
        end
        body = {
            from: (page - 1) * per_page,
            size: per_page,
            query: must_conditions.any? ? { bool: { must: must_conditions } } : { match_all: {} },
            aggs: {
                subcategories: {
                    terms: { field: "subcategory" } 
                }
            }
        }

        if post_filters.any?
            body[:post_filter] = { bool: { filter: post_filters } }
        end
        response = ES_CLIENT.search(index: 'products', body: body)
        
        render json: {
            products: response["hits"]["hits"].map { |h| h["_source"]},
            filters: { 
                subcategories: response.dig("aggregations", "subcategories", "buckets")&.map { |b| b["key"] } || []
            },
            total: response.dig("hits", "total", "value") || 0
        }
    end
 
  
    def dynamic_category
        full_input = params[:filter_slug]
        return render json: { error: "Invalid input" }, status: :bad_request if full_input.blank?
        parts = full_input.split('&')
        rule_slug = parts.shift
        rule = FilterRule.find_by(filter_name: rule_slug)
        return render json: { error: "Rule '#{rule_slug}' not found" }, status: :not_found unless rule
        params_hash = {}
        parts.each do |part|
            key, value = part.split(':')
            next if key.blank? || value.blank?
            params_hash[key] = value
        end
        cache_key = [
                        rule_slug,
                        params_hash.sort.to_h
                    ]
        result_products = Rails.cache.fetch("dynamicCategory:#{cache_key}", expires_in: 10.minutes) do 
            Rails.logger.info("CACHE MISS,#{cache_key}")
            query_filters = []
            post_filters = []
            query_string = params_hash["q"]
            page = (params_hash["page"] || 1).to_i
            per_page = (params_hash["per_page"] || 10).to_i
            condition = JSON.parse(rule.filter_condition)
            condition.each do |field, value|
                if ["category", "subcategory"].include?(field.to_s)
                    operator = value.is_a?(Array) ? :terms : :term
                    query_filters << { operator => { field => value } }
                else
                    post_filters << (
                        value.is_a?(Hash) ?
                        { range: { field => value } } :
                        { term: { field => value } }
                    )
                end
            end
            post_filters << { range: { price: { gte: params_hash["min_price"].to_i} } } if params_hash["min_price"].present?
            post_filters << { range: { price: { lte: params_hash["max_price"].to_i} } } if params_hash["max_price"].present?
            body = {
                from: (page - 1) * per_page,
                size: per_page,
                query: {
                bool: {
                    must: query_string.present? ?
                    {
                        multi_match: {
                        query: query_string,
                        fields: ["productname", "subcategory"]
                        }
                    } :
                    { match_all: {} },

                    filter: query_filters
                }
                },
                post_filter: {
                    bool: {
                        filter: post_filters
                    }
                },
                aggs: {
                    discovered_category: {
                        terms: { field: "category"}
                    }
                }
            }
            response = ES_CLIENT.search(index: 'products', body: body)
            hits = response["hits"]["hits"]
            hits=hits.map { |h| h["_source"] }
            category_buckets = response["aggregations"]["discovered_category"]["buckets"]
            found_category = category_buckets.map { |b| b["key"] }.join(", ")
            { 
                metadata:{
                total_count: response["hits"]["total"]["value"],
                current_page: page,
                category: found_category.presence || "Unknown"
                },
                products: hits
            }
        end
        render json: result_products
    end

    private
    def user_params
        params.permit(:productname, :price, :category, :subcategory)
    end
end