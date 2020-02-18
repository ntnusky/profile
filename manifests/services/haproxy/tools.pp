# Installs and configures a utility for simple management of the haproxy service
# while its running.
class profile::services::haproxy::tools {
  $configfile = lookup({
    'name'          => 'profile::haproxy::tools::configfile',
    'default_value' => '/etc/haproxy/toolconfig.csv',
  })

  concat { $configfile:
    ensure         => present,
    ensure_newline => true, 
    owner          => 'root',
    group          => 'root',
    mode           => '0644',
  }

  concat::fragment{ 'haproxytools config header':
    target  => $configfile,
    content => '# This file is managed by puppet',
    order   => '01'
  }

  sudo::conf { 'haproxy-manage':
    priority => 50,
    source   => 'puppet:///modules/profile/sudo/haproxy-manage_sudoers',
  }

  file { '/usr/local/sbin/haproxy-manage.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/haproxy-manage.sh',
  }
}
