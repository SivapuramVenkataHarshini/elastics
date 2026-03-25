# Connect Rails directly to the Elasticsearch engine
# Replace 'YOUR_PASSWORD' with your actual elastic password
Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: "https://localhost:9200",
  user: "elastic",
  password: "_oWLKDaoL*MTJlYfFd-W",
  transport_options: { ssl: { verify: false } } # Use this if you are using self-signed certs locally
)

ES_CLIENT = Elasticsearch::Client.new(
  url: "https://localhost:9200",
  user: "elastic",
  password: "_oWLKDaoL*MTJlYfFd-W",
  transport_options: { ssl: { verify: false } } # Use this if you are using self-signed certs locally
)  