# Installs the puppetmaster with r10k.
class profile::services::puppet::server::install {
  $r10krepo = lookup('profile::puppet::r10k::repo', Stdlib::HTTPUrl)
  $adminmail = lookup('profile::admin::maillist', {
    'value_type'    => String,
    'default_value' => 'root',
  })

  package { 'puppetserver':
    ensure => 'present',
  }

  class { 'r10k':
    remote => $r10krepo,
  }
}
