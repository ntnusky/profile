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
  $reponame = lookup('profile::openvox::release', {
    'default_value' => 'openvox8',
    'value_type'    => String,
  })

  include ::profile::repo::openvox
  include ::profile::services::puppet::altnames

  if($collection =~ /openvox/) {
    $options = {
      'manage_repo' => false,
      'package_name' => 'openvox-agent',
    }
  } else {
    $options = {
      'collection' => $collection,
    }
  }

  $config = [
    {'section' => 'agent', 'setting' => 'environment', 'value' => $environment},
    {'section' => 'agent', 'setting' => 'runinterval', 'value' => $runinterval},
  ]

  class { 'puppet_agent':
    config  => $config,
    require => Apt::Source["${reponame}-release"],
    *       => $options,
  }

  # Apparantly the puppet_agent class refuses to configure arbritary parameters,
  # so we need to fix the rest ourselves...
  $agentconfigfile = '/etc/puppetlabs/puppet/puppet.conf'

  ini_setting { 'Puppet server':
    ensure  => present,
    path    => $agentconfigfile,
    section => 'agent',
    setting => 'server',
    value   => $puppetserver,
  }
  ini_setting { 'Puppet caserver':
    ensure  => present,
    path    => $agentconfigfile,
    section => 'agent',
    setting => 'ca_server',
    value   => $caserver,
  }
}
