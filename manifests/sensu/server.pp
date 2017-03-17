# Install and configure sensu-server and dashboard
class profile::sensu::server {
  require ::profile::services::redis

  $rabbithost = hiera('profile::rabbitmq::ip')
  $sensurabbitpass = hiera('profile::sensu::rabbit_password')
  $mgmt_nic = hiera('profile::interfaces::management')
  $sensu_url = hiera('profile::sensu::mailer::url')
  $mail_from = hiera('profile::sensu::mailer::mail_from')
  $mail_to = hiera('profile::sensu::mailer::mail_to')
  $smtp_address = hiera('profile::sensu::mailer::smtp_address')
  $smtp_port = hiera('profile::sensu::mailer::smtp_port')
  $smtp_domain = hiera('profile::sensu::mailer::smtp_domain')
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
    server                      => true,
    api                         => true,
    use_embedded_ruby           => true,
    api_bind                    => '127.0.0.1',
    sensu_plugin_provider       => 'sensu_gem',
    subscriptions               => $subscriptions,
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
  }

  sensu::plugin { 'sensu-plugins-mailer':
    type => 'package'
  }

  include ::profile::sensu::checks
  include ::profile::sensu::plugins
  include ::profile::sensu::uchiwa
}
