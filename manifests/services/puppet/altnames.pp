# Configures the puppet alt-names.
class profile::services::puppet::altnames {
  $alt_names = hiera_array('profile::puppet::altnames')

  ini_setting { 'Puppet DNS alt':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'main',
    setting => 'dns_alt_names',
    value   => $alt_names,
  }
}
