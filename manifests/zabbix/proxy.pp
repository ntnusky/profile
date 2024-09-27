#Installs and configures a zabbix-proxy
class profile::zabbix::proxy {
  $zabbix_version = lookup('profile::zabbix::version', {
    'default_value' => '7.0',
    'value_type'    => String,
  })
  $servers = lookup('profile::zabbix::proxy::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })
  $psk = lookup('profile::zabbix::proxy::psk::key', {
    'value_type' => String,
  })
  $pskid = lookup('profile::zabbix::proxy::psk::identity', {
    'default_value' => 'Proxy PSK',
    'value_type'    => String,
  })
  $zabbix_ssh_private_key = lookup('profile::zabbix::ssh::privatekey', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })
  $zabbix_ssh_public_key = lookup('profile::zabbix::ssh::publickey', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })

  file { '/var/cache/zabbix-proxy':
    ensure  => directory,
    mode    => '0750',
    owner   => 'zabbix',
    group   => 'zabbix',
    before  => Class['zabbix::database::sqlite'],
    require => Package['zabbix-proxy-sqlite3'],
  }

  file { '/etc/zabbix/proxy.psk':
    ensure  => present,
    mode    => '0600',
    owner   => 'zabbix',
    group   => 'zabbix',
    content => $psk,
    require => Package['zabbix-proxy-sqlite3'],
  }

  file { '/etc/zabbix/sshkeys':
    ensure  => directory,
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0755',
    require => Class['zabbix::proxy'],
  }

  if ($zabbix_ssh_private_key) {
    file { '/etc/zabbix/sshkeys/id_rsa':
      ensure  => file,
      content => $zabbix_ssh_private_key,
      owner   => 'zabbix',
      group   => 'zabbix',
      mode    => '0600',
      require => File['/etc/zabbix/sshkeys'],
    }
  }

  if ($zabbix_ssh_public_key) {
    file { '/etc/zabbix/sshkeys/id_rsa.pub':
      ensure  => file,
      content => $zabbix_ssh_public_key,
      owner   => 'zabbix',
      group   => 'zabbix',
      mode    => '0644',
      require => File['/etc/zabbix/sshkeys'],
    }
  }

  ::profile::baseconfig::firewall::service::custom { 'zabbix-proxy':
    port     => 10051,
    protocol => 'tcp',
    v4source => $servers.map | $s | { "${s}/32" },
  }

  class { '::zabbix::proxy':
    database_type        => 'sqlite',
    database_name        => '/var/cache/zabbix-proxy/zabbixproxy.db',
    proxyconfigfrequency => 10,
    sshkeylocation       => '/etc/zabbix/sshkeys',
    startipmipollers     => 3,
    tlsaccept            => 'psk',
    tlsconnect           => 'psk',
    tlspskfile           => '/etc/zabbix/proxy.psk',
    tlspskidentity       => $pskid,
    zabbix_server_host   => join($servers, ';'),
    zabbix_version       => $zabbix_version,
  }

  ::sudo::conf { 'zabbix-proxy_sudoers':
    priority => 15,
    source   => 'puppet:///modules/profile/sudo/zabbix-proxy_sudoers',
  }
}
