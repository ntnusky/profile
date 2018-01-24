# Installs a script which ensures that all tftp-servers are containing the same
# set of files which the routers can download. Used for ACL distribution.
class profile::services::tftp::acl {
  @@ssh_authorized_key { "routeracl-${::fqdn}":
    user    => 'root',
    type    => 'ssh-rsa',
    key     => $::facts['ssh']['rsa']['key'],
    tag     => 'routeracl-hostkeys',
    require => File['/root/.ssh'],
  }

  Ssh_authorized_key <<| tag == 'routeracl-hostkeys' |>>

  file { '/usr/local/sbin/pull_acl.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/pull_acl.sh',
  }

  cron { 'TFTP ACL sync':
    command => '/usr/local/sbin/pull_acl.sh',
    user    => 'root',
    minute  => '*',
  }
}
