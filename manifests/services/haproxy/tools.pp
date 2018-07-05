# Installs and configures a utility for simple management of the haproxy service
# while its running.
class profile::services::haproxy::tools {
  $configfile = lookup({
    'name'          => 'profile::haproxy::tools::configfile',
    'default_value' => '/etc/haproxy/toolconfig.txt',
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
}
