# Create a custom-fact containing the region-name, thus enabling us to use this 
# variable in hiera
class profile::baseconfig::facts {
  $region = lookup('ntnuopenstack::region', {
    'default_value' => undef,
    'value_type'    => Optional[String],
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

  if($region) {
    file { '/etc/puppetlabs/facter/facts.d/openstack.yaml':
      ensure  => 'file',
      mode    => '0644',
      content => to_yaml( {
        openstack => {
          region => $region,
        },
      } ),
      require => File['/etc/puppetlabs/facter/facts.d'],
    }
  } else {
    file { '/etc/puppetlabs/facter/facts.d/openstack.yaml':
      ensure => absent,
    }
    warning { "There is no region set in hiera." }
  }
}
