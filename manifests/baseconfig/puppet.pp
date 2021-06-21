# This class installs and configures puppet.
class profile::baseconfig::puppet {
  include ::puppet_agent::service

  $environment = lookup('profile::puppet::environment', String)
  $runinterval = lookup('profile::puppet::runinterval', {
    'default_value' => '30m',
    'value_type'    => String,
  })
  $puppetserver = lookup('profile::puppet::hostname', Stdlib::Fqdn)
  $caserver = lookup('profile::puppet::caserver', Stdlib::Fqdn)

  $collection = lookup('profile::puppet::collection', {
    'value_type' => String,
  })

  include ::profile::services::puppet::altnames

  $config = [
    {'section' => 'agent', 'setting' => 'environment', 'value' => $environment},
    {'section' => 'agent', 'setting' => 'runinterval', 'value' => $runinterval},
  ]

  class { 'puppet_agent':
    config     => $config,
    collection => $collection,
  }

  # Apparantly the puppet_agent class refuses to configure arbritary parameters,
  # so we need to fix the rest ourselves...
  $agentconfigfile = '/etc/puppetlabs/puppet/puppet.conf'
  $agentpackage = 'puppet-agent'

  ini_setting { 'Puppet server':
    ensure  => present,
    path    => $agentconfigfile,
    section => 'agent',
    setting => 'server',
    value   => $puppetserver,
    notify  => Service['puppet'],
    require => Package[$agentpackage],
  }
  ini_setting { 'Puppet caserver':
    ensure  => present,
    path    => $agentconfigfile,
    section => 'agent',
    setting => 'ca_server',
    value   => $caserver,
    notify  => Service['puppet'],
    require => Package[$agentpackage],
  }
}
