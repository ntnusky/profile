# Create a custom-fact containing the region-name, thus enabling us to use this 
# variable in hiera
class profile::baseconfig::facts {
  $region = lookup('ntnuopenstack::region', {
    'value_type' => String,
  })

  file { '/etc/puppetlabs/facter':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  -> file { '/etc/puppetlabs/facter/facts.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  -> file { '/etc/puppetlabs/facter/facts.d/openstack.yaml':
    ensure  => 'file',
    mode    => '0644',
    content => to_yaml( { region => $region } ),
  }
}
