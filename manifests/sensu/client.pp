# Install and configure sensu-client
class profile::sensu::client {
  $rabbithost = hiera('profile::rabbitmq::ip')
  $sensurabbitpass = hiera('profile::sensu::rabbit_password')
  $mgmt_nic = hiera('profile::interfaces::management','ens3')
  $client_ip = getvar("::ipaddress_${mgmt_nic}")

  if ( $::is_virtual == 'true' ) {
    $subscriptions = [ 'all' ]
  } else {
    $subscriptions = [ 'all', 'physical-servers' ]
  }

  class { '::sensu':
    rabbitmq_host               => $rabbithost,
    rabbitmq_password           => $sensurabbitpass,
    rabbitmq_reconnect_on_error => true,
    server                      => false,
    api                         => false,
    client                      => true,
    client_address              => $client_ip,
    sensu_plugin_provider       => 'sensu_gem',
    use_embedded_ruby           => true,
    subscriptions               => $subscriptions,
  }

  include ::profile::sensu::plugins
}
