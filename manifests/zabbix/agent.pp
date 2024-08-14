# This class installs a zabbix-agent
class profile::zabbix::agent {
  $zabbix_version = lookup('profile::zabbix::version', {
    'default_value' => '7.0',
    'value_type'    => String,
  })
  $servers = lookup('profile::zabbix::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  # If the array contains at least one element:
  if($servers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    ::profile::baseconfig::firewall::service::management { 'zabbix-agent':
      port     => [ 10050 ],
      protocol => 'tcp',
    }

    class { 'zabbix::agent':
      agent_configfile_path => '/etc/zabbix/zabbix_agent2.conf',
      include_dir           => '/etc/zabbix/zabbix_agent2.d',
      include_dir_purge     => false,
      manage_startup_script => false,
      server                => $servers, 
      servicename           => 'zabbix-agent2',
      zabbix_package_agent  => 'zabbix-agent2',
      zabbix_version        => $zabbix_version,
    }
  }
}
