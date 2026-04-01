class ProductsController < ApplicationController
    skip_before_action :verify_authenticity_token
    def create
        data=Product.create(user_params)
        
        render json: data
    end
    def adding
        Product.add_product
        render json: { message: "Sync started" }
    end

    # def updating
    #     @product = Product.find(params[:id]) 
    #     if @product.update_with_elasticsearch(user_params)
    #         render json: @product
    #     else
    #         render json: { errors: "Update failed" }, status: :unprocessable_entity
    #     end
    # end

    # def deleting
    #     @product = Product.find(params[:id])
    #     if @product.delete_with_elasticsearch
    #         render json: { message: "Deleted" }
    #     else
    #         render json: { error: "Delete failed" }, status: :error
    #     end
    # end

    def index
        render json: Product.all
    end
    def show
        product = Product.find(params[:id])
        render json: product
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
        allowed_sort_fields = ["price", "productname", "best_seller"]
        sort_by = params[:sort_by].presence_in(allowed_sort_fields) 
        sort_order = params[:sort_order].presence_in(["asc", "desc"]) || "asc"
        es_sort_field = sort_by == "productname" ? "productname.keyword" : sort_by
        sort_clause = [{ es_sort_field=> { order: sort_order } }]

        must_queries = []
        filters = []
        if params[:q].present?
            must_queries << {
            multi_match: {
                query: params[:q],
                fields: ["productname", "category", "subcategory"]
            }
            }
        end
        if params[:category].present?
            filters << { term: { "category.keyword": params[:category] } }
            category_for_subcategory = params[:category]
        else
            category_for_subcategory = nil
        end

        if params[:subcategory].present?
            filters << { term: { "subcategory.keyword": params[:subcategory] } }
            if params[:category].blank?
            cat_resp = ES_CLIENT.search(
                index: 'products',
                body: {
                size: 1,
                query: {
                    match: { "subcategory.keyword": params[:subcategory] }
                }
                }
            )
            if cat_resp["hits"]["hits"].any?
                category_for_subcategory = cat_resp["hits"]["hits"][0]["_source"]["category"]
                # Add category filter
                filters << { term: { "category.keyword": category_for_subcategory } }
            end
            end
        end

        if params[:min_price].present? || params[:max_price].present?
            filters << {
            range: {
                price: {
                gte: params[:min_price] || 0,
                lte: params[:max_price] || 999_999
                }
            }
            }
        end

        query_body = if must_queries.any? || filters.any?
            { bool: { must: must_queries, filter: filters } }
        else
            { match_all: {} }
        end

        body = {
            from: (page - 1) * per_page,
            size: per_page,
            query: query_body,
            sort: sort_clause
        }

        body[:aggs] = if category_for_subcategory
            {
            subcategories: {
                global: {},
                aggs: {
                by_category: {
                    filter: { term: { "category.keyword": category_for_subcategory } },
                    aggs: { names: { terms: { field: "subcategory.keyword", size: 100 } } }
                }
                }
            }
            }
        else
            { subcategories: { terms: { field: "subcategory.keyword", size: 100 } } }
        end

        response = ES_CLIENT.search(index: 'products', body: body)

        products = response["hits"]["hits"].map do |hit|
            {
                id: hit["_id"],
                name: hit["_source"]["productname"],
                price: hit["_source"]["price"],
                category: hit["_source"]["category"],
                subcategory: hit["_source"]["subcategory"]
            }
        end

        subcategories = if category_for_subcategory
            response["aggregations"]["subcategories"]["by_category"]["names"]["buckets"].map { |b| b["key"] }
        else
            response["aggregations"]["subcategories"]["buckets"].map { |b| b["key"] }
        end

        total = response["hits"]["total"]["value"]

        render json: {
            products: products,
            filters: { subcategories: subcategories },
            total: total
        }
    end
    private
    def user_params
        params.permit(:productname, :price, :category, :subcategory)
    end
end
