# This class installs a zabbix-agent
class profile::zabbix::agent {

  include ::zabbix::params

  $zabbix_version = lookup('profile::zabbix::version', {
    'default_value' => '7.0',
    'value_type'    => String,
  })
  $servers = lookup('profile::zabbix::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  $agent_config_file = '/etc/zabbix/zabbix_agent2.conf'
  $servicename = 'zabbix-agent2'
  $user = 'zabbix_agent'
  $package_agent = $servicename

  # If the array contains at least one element:
  if($servers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    ::profile::baseconfig::firewall::service::infra { 'zabbix-agent':
      port     => [ 10050 ],
      protocol => 'tcp',
    }

    user { $user:
      ensure => 'present',
      system => true,
    }

    class { 'zabbix::agent':
      agent_configfile_path => $agent_config_file,
      include_dir           => '/etc/zabbix/zabbix_agent2.d',
      include_dir_purge     => false,
      manage_startup_script => false,
      pidfile               => '/var/run/zabbix_agent/zabbix_agentd.pid'
      server                => join($servers, ','),
      servicename           => $servicename,
      zabbix_package_agent  => $package_agent,
      zabbix_version        => $zabbix_version,
      require               => User['zabbix_agent'],
    }

    systemd::dropin_file { 'zabbix-agent2-overrides.conf':
      unit    => "${servicename}.service",
      content => epp('profile/zabbix_agent/zabbix_agent.epp', {
        'zabbix_user'  => $user,
        'zabbix_group' => $user,
      }),
      notify  => Service[$servicename],
    }
  }
}
