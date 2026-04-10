# Connect Rails directly to the Elasticsearch engine
# Replace 'YOUR_PASSWORD' with your actual elastic password

ES_CLIENT = Elasticsearch::Client.new(
  url: 'http://localhost:9200',
  log: true
)