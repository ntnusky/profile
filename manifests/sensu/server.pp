# Install and configure sensu-server and dashboard
class profile::sensu::server {

  $rabbithost = hiera('profile::rabbitmq::ip', false)
  $rabbithosts = hiera('profile::rabbitmq::servers',false)
  $sensurabbitpass = hiera('profile::sensu::rabbit_password')
  $mgmt_nic = hiera('profile::interfaces::management')
  $sensu_url = hiera('profile::sensu::mailer::url')
  $mail_from = hiera('profile::sensu::mailer::mail_from')
  $mail_to = hiera('profile::sensu::mailer::mail_to')
  $smtp_address = hiera('profile::sensu::mailer::smtp_address')
  $smtp_port = hiera('profile::sensu::mailer::smtp_port')
  $smtp_domain = hiera('profile::sensu::mailer::smtp_domain')
  $subs_from_client_conf = hiera('sensu::subscriptions','')
  $redishost = hiera('profile::redis::ip')
  $redismasterauth = hiera('profile::redis::masterauth')

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
