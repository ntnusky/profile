# Install and configure sensu-client
class profile::sensu::client {
  $mgmt_nic = lookup('profile::interfaces::management', {
    'value_type'   => Variant[String, Boolean],
    'default_type' => false,
  })

  if($mgmt_nic) {
    $rabbithost = lookup('profile::rabbitmq::ip', {
      'value_type' => Variant[Stdlib::IP::Address::V4, Boolean],
      'default_value' => false,
    })
    $rabbithosts = lookup('profile::rabbitmq::servers', {
      'value_type'    => Variant[Array[String], Boolean],
      'default_value' => false,
    })
    $sensurabbitpass = lookup('profile::sensu::rabbit_password', String)
    $client_ip = getvar("::ipaddress_${mgmt_nic}")
    $subs_from_client_conf = lookup('sensu::subscriptions', {
      'value_type'    => Variant[Array[String], String],
      'default_value' => '',
    })

    include ::profile::sensu::plugins

    if ( ! $rabbithost ) and ( ! $rabbithosts ) {
      error('You need to specify either a single rabbithost, or a list of hosts')
    }

    if ( $::is_virtual ) {
      $subs = [ 'all' ]
    } else {
      if ( $::facts['dmi']['manufacturer'] =~ /Dell/ ) {
        $subs = [ 'all', 'physical-servers', 'dell-servers']
      } else {
        $subs = [ 'all', 'physical-servers' ]
      }
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
