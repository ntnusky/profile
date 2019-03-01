# Install and configure sensu-server and dashboard
class profile::sensu::server {

  $rabbithost = lookup('profile::rabbitmq::ip', {
    'value_type'   => Variant[Stdlib::IP::Address::V4, Boolean],
    'default_value' => false,
  })
  $rabbithosts = lookup('profile::rabbitmq::servers', {
    'value_type'    => Variant[Array[String], Boolean],
    'default_value' => false,
  })
  $sensurabbitpass = lookup('profile::sensu::rabbit_password', String)
  $mgmt_nic = lookup('profile::interfaces::management', String)
  $sensu_url = lookup('profile::sensu::mailer::url', Variant[Stdlib::Httpsurl, Stdlib::Httpurl])
  $mail_from = lookup('profile::sensu::mailer::mail_from', String)
  $mail_to = lookup('profile::sensu::mailer::mail_to', Array[String])
  $smtp_address = lookup('profile::sensu::mailer::smtp_address', Stdlib::Fqdn)
  $smtp_port = lookup('profile::sensu::mailer::smtp_port', Integer)
  $smtp_domain = lookup('profile::sensu::mailer::smtp_domain', Stdlib::Fqdn)
  $subs_from_client_conf = lookup('sensu::subscriptions', {
    'value_type'    => Variant[Array[String], String],
    'default_value' => '',
  })
  $redishost = lookup('profile::redis::ip', Variant[Stdlib::IP::Address, Stdlib::Fqdn])
  $redismasterauth = lookup('profile::redis::masterauth', String)

  if ( ! $rabbithost ) and ( ! $rabbithosts ) {
    error('You need to specify either a single rabbithost, or a list of hosts')
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
    redis_host                   => $redishost,
    redis_password               => $redismasterauth,
    redis_reconnect_on_error     => true,
    server                       => true,
    api                          => true,
    use_embedded_ruby            => true,
    api_bind                     => '127.0.0.1',
    sensu_plugin_provider        => 'sensu_gem',
    subscriptions                => $subscriptions,
    purge                        => true,
    *                            => $transport_conf,
  }

  sensu::handler { 'default':
    type     => 'set',
    handlers => [ 'stdout', 'mailer' ],
  }

  sensu::handler { 'stdout':
    type    => 'pipe',
    command => 'cat',
  }

  sensu::handler { 'mailer':
    type    => 'pipe',
    command => 'handler-mailer.rb',
    config  => {
      admin_gui    => $sensu_url,
      mail_from    => $mail_from,
      mail_to      => $mail_to,
      smtp_address => $smtp_address,
      smtp_port    => $smtp_port,
      smtp_domain  => $smtp_domain,
    },
    filters => [ 'state-change-only' ],
  }

  sensu::plugin { 'sensu-plugins-mailer':
    type => 'package'
  }

  sensu::filter { 'state-change-only':
    negate     => false,
    attributes => {
      occurrences => "eval: value == 1 || ':::action:::' == 'resolve'",
    },
  }

  include ::profile::sensu::checks
  include ::profile::sensu::plugins
  include ::profile::sensu::plugin::http
  include ::profile::sensu::uchiwa
}
