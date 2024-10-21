# Create a custom-fact containing the region-name, thus enabling us to use this 
# variable in hiera
class profile::baseconfig::facts {
  $region = lookup('profile::region', {
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
    file { '/etc/puppetlabs/facter/facts.d/ntnu.yaml':
      ensure  => 'file',
      mode    => '0644',
      content => to_yaml( {
        ntnu => {
          region => $region,
        },
      } ),
      require => File['/etc/puppetlabs/facter/facts.d'],
    }
    file { '/etc/puppetlabs/facter/facts.d/openstack.yaml':
      ensure => absent,
    }
  } else {
    file { '/etc/puppetlabs/facter/facts.d/ntnu.yaml':
      ensure => absent,
    }
    file { '/etc/puppetlabs/facter/facts.d/openstack.yaml':
      ensure => absent,
    }
    notify { 'Missing region':
      message => 'There is no region defined for this host in hiera',
    }
  }
}
