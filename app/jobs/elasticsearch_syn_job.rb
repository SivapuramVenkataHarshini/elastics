class ElasticsearchSynJob < ApplicationJob
  queue_as :default

  def perform(action, product_id, data = nil)
    case action
    when 'index'
      ES_CLIENT.index(
        index: 'products',
        id: product_id,
        body: data
      )
    when 'update'
      ES_CLIENT.update(
        index: 'products',
        id: product_id,
        body: { doc: data }
      )

    when 'delete'
      ES_CLIENT.delete(
        index: 'products',
        id: product_id
      )
  end
  rescue => e
    Rails.logger.error("Elasticsearch Error: #{e.message}")
  end
end
