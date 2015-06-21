# logstashforwarder
class profile::monitoring::logstashforwarder {

# BLOCK OF SSL KEYS TO BE REQUIRED BY logstashforwarder

  class { '::logstashforwarder':
    servers     => [ 'monitor.skyhigh:9300' ],
    ssl_key     => 'puppet:///modules/profile/keys/private/logstash-forwarder.key',
    ssl_ca      => 'puppet:///modules/profile/keys/certs/selfsigned.crt',
    ssl_cert    => 'puppet:///modules/profile/keys/certs/logstash-forwarder.crt',
    manage_repo => true,
    autoupgrade => true,
  }

  logstashforwarder::file { 'syslog':
    paths  => [ '/var/log/syslog' ],
    fields => { 'type' => 'syslod' },
  }

}
