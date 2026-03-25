class Product < ApplicationRecord
    # include Elasticsearch::Model
    # settings index: {number_of_shards: 1} do
    #     mapping dynamic: 'false' do
    #         indexes :productname, type: 'text' ,analyzer: 'english'
    #         indexes :price, type: 'float'
    #         indexes :category, type: 'text', analyzer: 'english'
    #     end
    # end
    def as_indexed_json(options={})
        {
            id: id,
            productname: productname,
            price: price,
            category: category
        }
    end

    # def sync_to_elasticsearch
    #     __elasticsearch__.index_document
    # end
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
                        product_name: { type: 'text' },
                        price: { type: 'integer' },
                        category: { type: 'keyword' }
                    }
                }
            }
        )
    end

    def self.add_product
        Product.find_each do |product|
            ES_CLIENT.index(
                index: 'products',
                id: product.id,
                body: {
                productname: product.productname,
                price: product.price,
                category: product.category
                }
            )
        end
    end

    def update_with_elasticsearch(params)
        if self.update(params)
            ES_CLIENT.update(
                index: 'products',
                id: self.id,
                body: {
                    doc:{
                        productname: self.productname,
                        price: self.price,
                        category: self.category
                    }
                }
            )
            return true
        else
            return false
        end
    end
    def delete_with_elasticsearch
        if self.delete
            ES_CLIENT.delete(
                index: 'products',
                id: self.id
            )
            return true
        else
            return false
        end
    end
end
