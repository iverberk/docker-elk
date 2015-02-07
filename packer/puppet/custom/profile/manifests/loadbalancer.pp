class profile::loadbalancer (
  $listening_service,
  $listen = {},
  $balancermembers = {},
  $keepalived_instance = {}
) {

  # Enable syslog (udp) for HAProxy
  file { '/etc/rsyslog.d/haproxy.conf':
    ensure => present,
    owner => 'root',
    group => 'root',
    source => "puppet:///modules/${module_name}/loadbalancer/haproxy.conf",
  }

  # Keepalived check script
  keepalived::vrrp::script { 'chk_haproxy':
    script => 'killall -0 haproxy',
    weight => 2
  }

  # Allow virtual ip
  file { '/etc/sysctl.d/keepalived.conf':
    ensure => present,
    owner => 'root',
    group => 'root',
    content => 'net.ipv4.ip_nonlocal_bind=1'
  }

  exec { "sysctl-keepalived":
    command     => "/sbin/sysctl -p /etc/sysctl.d/keepalived.conf",
    refreshonly => true,
    require     => File["/etc/sysctl.d/keepalived.conf"],
  }

  include haproxy
  include keepalived

  create_resources('haproxy::listen', $listen)
  create_resources('haproxy::balancermember', $balancermembers)
  create_resources('keepalived::vrrp::instance', $keepalived_instance)

}