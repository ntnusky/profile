# logstashforwarder
class profile::monitoring::logstashforwarder {

  $logstashserver = hiera('profile::monitoring::logstashserver')

  class { '::logstashforwarder':
    servers     => [ "${logstashserver}" ],
#    ssl_key     => 'puppet:///modules/profile/keys/private/logstash-forwarder.key',
    ssl_ca      => 'puppet:///modules/profile/keys/certs/selfsigned.crt',
#    ssl_cert    => 'puppet:///modules/profile/keys/certs/logstash-forwarder.crt',
    manage_repo => true,
    autoupgrade => true,
  }

  logstashforwarder::file { 'syslog':
    paths  => [ '/var/log/syslog', '/var/log/auth.log' ],
    fields => { 'type' => 'syslog' },
  }
  logstashforwarder::file { 'nova':
    paths  => [ '/var/log/nova/*.log' ],
    fields => { 'type' => 'openstack', 'component' => 'nova' },
  }
  logstashforwarder::file { 'neutron':
    paths  => [ '/var/log/neutron/*.log' ],
    fields => { 'type' => 'openstack', 'component' => 'neutron' },
  }
  logstashforwarder::file { 'cinder':
    paths  => [ '/var/log/cinder/*.log' ],
    fields => { 'type' => 'openstack', 'component' => 'cinder' },
  }
  logstashforwarder::file { 'heat':
    paths  => [ '/var/log/heat/*.log' ],
    fields => { 'type' => 'openstack', 'component' => 'heat' },
  }
  logstashforwarder::file { 'keystone':
    paths  => [ '/var/log/keystone/*.log' ],
    fields => { 'type' => 'openstack', 'component' => 'keystone' },
  }
  logstashforwarder::file { 'glance':
    paths  => [ '/var/log/glance/*.log' ],
    fields => { 'type' => 'openstack', 'component' => 'glance' },
  }
  logstashforwarder::file { 'ceilometer':
    paths  => [ '/var/log/ceilometer/*.log' ],
    fields => { 'type' => 'openstack', 'component' => 'ceilometer' },
  }
  logstashforwarder::file { 'libvirt':
    paths  => [ '/var/log/libvirt/*.log' ],
    fields => { 'type' => 'libvirt' },
  }
  logstashforwarder::file { 'ceph':
    paths  => [ '/var/log/ceph/*.log' ],
    fields => { 'type' => 'ceph' },
  }

}
