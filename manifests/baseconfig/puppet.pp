# This class installs and configures puppet.
class profile::baseconfig::puppet {
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
    {'section' => 'agent', 'setting' => 'server', 'value' => $puppetserver},
    {'section' => 'agent', 'setting' => 'ca_server', 'value' => $caserver},
  ]

  class { 'puppet_agent':
    config     => $config,
    collection => $collection,
  }
}
