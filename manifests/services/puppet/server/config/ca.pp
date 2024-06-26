# Either enables or disables the puppetCA feature, depending if this server
# should be CA or not.
class profile::services::puppet::server::config::ca {
  $puppetca = lookup('profile::puppet::caserver', Stdlib::Fqdn)

  if($puppetca == $::fqdn) {
    $template = 'ca.enabled.cfg'

    file { '/etc/puppetlabs/puppetserver/conf.d/ca.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///modules/profile/puppet/ca.conf',
      notify  => Service['puppetserver'],
      require => Package['puppetserver'],
    }
  } else {
    $template = 'ca.disabled.cfg'
  }

  file { '/etc/puppetlabs/puppetserver/services.d/ca.cfg':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/profile/puppet/${template}",
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }
}
