# Install and configure sensu-client
class profile::sensu::client {
  $rabbithost = hiera('profile::rabbitmq::ip')
  $sensurabbitpass = hiera('profile::sensu::rabbit_password')
  $mgmt_nic = hiera('profile::interfaces::management')
  $client_ip = getvar("::ipaddress_${mgmt_nic}")
  $subs_from_client_conf = hiera('sensu::subscriptions','')

  if ( $::is_virtual == 'true' ) {
    $subs = [ 'all' ]
  } else {
    $subs = [ 'all', 'physical-servers' ]
  }

  if ( $subs_from_client_conf != '' )  {
    $subscriptions = concat($subs, $subs_from_client_conf)
  } else {
    $subscriptions = $subs
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
    purge                       => true,
  }

  include ::profile::sensu::plugins
}
