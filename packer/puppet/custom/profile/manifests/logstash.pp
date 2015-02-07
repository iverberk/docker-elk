class logstash (
  $plugins          = {},
  $es_instance      = "",
  $redis_instances,
  $role
) {

  $roles = [
    'indexer',
    'shipper'
  ]

  validate_array($redis_instances)
  validate_hash($plugins)
  validate_re($role, $roles)
  validate_string($es_instance)

  $joined_redis_instances = join($redis_instances, ",")

  # Common Logstash module
  include ::logstash

  create_resources('logstash::plugin', $plugins)

  if $role == 'indexer' {

    logstash::configfile { 'indexer':
      content => template('profile/logstash/indexer.conf.erb'),
    }

  }

  if $role == 'shipper' {

    class { 'redis':
      redis_user => 'redis',
      redis_group => 'redis'
    }
    
    logstash::configfile { 'shipper':
      content => template('profile/logstash/shipper.conf.erb'),
    }  

  }

}