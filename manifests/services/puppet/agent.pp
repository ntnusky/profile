# This class installs and configures the puppet agent.
class profile::services::puppet::agent {
  $alt_names = lookup('profile::puppet::altnames', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::Fqdn],
  })
  $environment = lookup('profile::puppet::environment', String)
  $runinterval = lookup('profile::puppet::runinterval', {
    'default_value' => '30m',
    'value_type'    => String,
  })
  $puppetserver = lookup('profile::puppet::hostname', Stdlib::Fqdn)
  $caserver = lookup('profile::puppet::caserver', Stdlib::Fqdn)

  $reponame = lookup('profile::openvox::release', {
    'default_value' => 'openvox8',
    'value_type'    => String,
  })

  include ::profile::repo::openvox

  class { '::puppet':
    agent_server_hostname => $puppetserver, 
    dns_alt_names         => $alt_names,
    environment           => $environment,
    manage_packages       => true,
    runinterval           => $runinterval,
    runmode               => 'service',
    unavailable_runmodes  => ['systemd.timer', 'cron'],
    require               => Apt::Source["${reponame}-release"],
  }

  puppet::config::agent { 'ca_server':
    value => $caserver,
  }
}
