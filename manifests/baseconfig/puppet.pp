# This class installs and configures puppet.
class profile::baseconfig::puppet {
  $alt_names = lookup('profile::puppet::altnames', {
    'default_value' => false,
    'value_type'    => Variant[Array[Stdlib::Fqdn], Boolean],
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
    require               => Apt::Source["${reponame}-release"],
  }

  # Apparantly the puppet_agent class refuses to configure arbritary parameters,
  # so we need to fix the rest ourselves...
  $agentconfigfile = '/etc/puppetlabs/puppet/puppet.conf'

  ini_setting { 'Puppet caserver':
    ensure  => present,
    path    => $agentconfigfile,
    section => 'agent',
    setting => 'ca_server',
    value   => $caserver,
  }
}
