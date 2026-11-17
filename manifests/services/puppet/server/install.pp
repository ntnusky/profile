# Installs the puppetmaster with r10k.
class profile::services::puppet::server::install {
  $package = lookup('profile::puppet::server::package', {
    # TODO: Switch default to openvox after we have migrated.
    'default_value' => 'puppetserver',
    'value_type'    => Enum['openvox-server', 'puppetserver'],
  })
  $r10krepo = lookup('profile::puppet::r10k::repo', Stdlib::HTTPUrl)

  package { 'puppetserver':
    ensure => 'present',
    name   => $package,
  }

  if($package == 'openvox-server') {
    package { 'openvoxdb-termini':
      ensure => 'present',
    }
  }

  class { 'r10k':
    remote => $r10krepo,
  }
}
