# Configures the puppetmaster to use hiera, and set up hiera replication between
# puppet masters
class profile::services::puppet::server::hiera {
  @@ssh_authorized_key { "puppetmaster-${::fqdn}":
    user    => 'root',
    type    => 'ssh-rsa',
    key     => $::facts['ssh']['rsa']['key'],
    tag     => 'puppetmaster-hostkeys',
    require => File['/root/.ssh'],
  }

  Ssh_authorized_key <<| tag == 'puppetmaster-hostkeys' |>>

  file { '/usr/local/sbin/pull_hiera.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/puppet/pull_hiera.sh',
  }

  file { '/usr/local/sbin/killr10k.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/puppet/killr10k.sh',
  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/profile/puppet/hiera.yaml',
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  cron { 'Puppet r10k killer':
    command => '/usr/local/sbin/killr10k.sh',
    user    => 'root',
    minute  => '*',
  }

  cron { 'Puppet hieradata sync':
    command => '/usr/local/sbin/pull_hiera.sh',
    user    => 'root',
    minute  => '*',
  }

  file { '/root/hieradata':
    ensure => link,
    target => '/etc/puppetlabs/puppet/data',
    owner  => 'root',
    group  => 'root',
  }
}
