# Configures the puppet alt-names.
class profile::services::puppet::altnames {
  $alt_names = lookup('profile::puppet::altnames', {
    'default_value' => false,
    'value_type'    => Variant[Array[Stdlib::Fqdn], Boolean],
  })

  if($alt_names) {
    ini_setting { 'Puppet DNS alt':
      ensure  => present,
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      section => 'main',
      setting => 'dns_alt_names',
      value   => join($alt_names, ','),
    }
  } else {
    ini_setting { 'Puppet DNS alt':
      ensure  => absent,
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      section => 'main',
      setting => 'dns_alt_names',
    }
  }
}
