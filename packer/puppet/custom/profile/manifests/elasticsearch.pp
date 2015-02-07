class elasticsearch (
  $instances = {},
  $plugins = {}
) {

  # Common Elasticsearch module
  include ::elasticsearch

  validate_hash($instances)
  validate_hash($plugins)

  create_resources('elasticsearch::instance', $instances)
  create_resources('elasticsearch::plugin', $plugins)

}