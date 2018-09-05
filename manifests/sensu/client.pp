# Install and configure sensu-client
class profile::sensu::client {
  $mgmt_nic = hiera('profile::interfaces::management', false)

  if($mgmt_nic) {
    $rabbithost = hiera('profile::rabbitmq::ip', false)
    $rabbithosts = hiera('profile::rabbitmq::servers',false)
    $sensurabbitpass = hiera('profile::sensu::rabbit_password')
    $client_ip = getvar("::ipaddress_${mgmt_nic}")
    $subs_from_client_conf = hiera('sensu::subscriptions','')

    include ::profile::sensu::plugins

    if ( ! $rabbithost ) and ( ! $rabbithosts ) {
      error('You need to specify either a single rabbithost, of a list of hosts')
    }

    if ( $::is_virtual ) {
      $subs = [ 'all' ]
    } else {
      $subs = [ 'all', 'physical-servers' ]
    }

    if ( $subs_from_client_conf != '' )  {
      $subscriptions = concat($subs, $subs_from_client_conf)
    } else {
      $subscriptions = $subs
    }

    if ( $rabbithosts ) {
      $rabbit_cluster = $rabbithosts.map |$host| {
        {
          port      => 5672,
          host      => $host,
          user      => 'sensu',
          password  => $sensurabbitpass,
          vhost     => '/sensu',
          heartbeat => 2,
          prefetch  => 1,
        }
      }
      $transport_conf = {
        rabbitmq_cluster => $rabbit_cluster
      }
    } else {
        $transport_conf = {
          rabbitmq_host     => $rabbithost,
          rabbitmq_user     => 'sensu',
          rabbitmq_password => $sensurabbitpass,
          rabbitmq_port     => 5672,
        }
    }

    class { '::sensu':
      transport_reconnect_on_error => true,
      server                       => false,
      api                          => false,
      client                       => true,
      client_address               => $client_ip,
      sensu_plugin_provider        => 'sensu_gem',
      use_embedded_ruby            => true,
      subscriptions                => $subscriptions,
      purge                        => true,
      *                            => $transport_conf,
    }
  }
}
