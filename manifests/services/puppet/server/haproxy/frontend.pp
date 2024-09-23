# Configures the haproxy in frontend for the puppetmasters 
class profile::services::puppet::server::haproxy::frontend {
  include ::profile::services::puppet::server::firewall

  $client_timeout = lookup('profile::puppet::haproxy::timeout::server', {
    'value_type'    => String,
    'default_value' => '1m',
  })
  $server_timeout = lookup('profile::puppet::haproxy::timeout::client', {
    'value_type'    => String,
    'default_value' => '1m',
  })

  ::profile::services::haproxy::frontend { 'puppetserver':
    profile   => 'management',
    port      => 8140,
    ftoptions => {
      'timeout' => [ "client ${client_timeout}" ]
    },
    bkoptions => {
      'timeout' => [ "server ${server_timeout}" ]
    },
  }
}
