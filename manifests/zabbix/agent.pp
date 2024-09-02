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

  $servicename = 'zabbix-agent2'
  $user = 'zabbix_agent'
  $package_agent = $servicename
  $pidfile_dir = '/var/run/zabbix_agent'

  # If the array contains at least one element:
  if($servers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    include ::profile::zabbix::agent::puppet

    ::profile::baseconfig::firewall::service::infra { 'zabbix-agent':
      port     => [ 10050 ],
      protocol => 'tcp',
    }

    user { $user:
      ensure => 'present',
      system => true,
    }

    class { 'zabbix::agent':
      agent_configfile_path => '/etc/zabbix/zabbix_agent2.conf',
      agent_config_owner    => $user,
      agent_config_group    => $user,
      include_dir           => '/etc/zabbix/zabbix_agent2.d',
      include_dir_purge     => false,
      manage_startup_script => false,
      pidfile               => '/var/run/zabbix_agent/zabbix_agentd.pid',
      server                => join($servers, ','),
      servicename           => $servicename,
      zabbix_package_agent  => $package_agent,
      zabbix_version        => $zabbix_version,
      require               => [User[$user],File[$pidfile_dir]]
    }

    systemd::dropin_file { 'zabbix-agent2-overrides.conf':
      unit    => "${servicename}.service",
      content => epp('profile/zabbix_agent/zabbix_agent.epp', {
        'zabbix_user'  => $user,
        'zabbix_group' => $user,
      }),
      notify  => Service[$servicename],
    }

    file { $pidfile_dir:
      ensure  => 'directory',
      mode    => '0755',
      owner   => $user,
      group   => $user,
      require => User[$user],
    }

    file { '/etc/zabbix/zabbix_agent2.d/plugins.conf':
      ensure  => 'file',
      mode    => '0644',
      owner   => $user,
      group   => $user,
      content => 'Include=/etc/zabbix/zabbix_agent2.d/plugins.d',
      require => Class['zabbix::agent'],
    }
  }
}
