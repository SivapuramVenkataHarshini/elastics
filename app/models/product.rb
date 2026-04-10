class Product < ApplicationRecord
    include Elasticsearch::Model
    after_commit :index_to_elasticsearch, on: [:create]
    after_commit :update_with_elasticsearch, on: [:update]
    after_commit :delete_from_elasticsearch, on: [:destroy]
    def as_indexed_json(options={})
        {
            id: id,
            productname: productname,
            price: price,
            category: category,
            subcategory: subcategory
        }
    end

    def index_to_elasticsearch
        ElasticsearchSynJob.perform_later('index', self.id,as_indexed_json)
    end

    def update_with_elasticsearch
        ElasticsearchSynJob.perform_later('update', self.id,as_indexed_json)
    end

    def delete_from_elasticsearch  
        ElasticsearchSynJob.perform_later('delete', self.id)
    end

    def self.create_index
        ES_CLIENT.indices.create(
        index: 'products',
            body: {
                settings: {
                number_of_shards: 1,
                number_of_replicas: 1
                },
                mappings: {
                    properties: {
                        productname: { type: 'text' },
                        price: { type: 'float' },
                        category: { type: 'keyword' },
                        subcategory: {type: 'keyword'}
                    }
                }
            }
        )
    end
    
end
