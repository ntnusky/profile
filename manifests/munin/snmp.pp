class profile::munin::snmp {
  munin::plugin { 'snmp_gw.skyhgih_if_1':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__if_',
	config => ['env.community skyhigh'],
  }
  munin::plugin { 'snmp_gw.skyhgih_if_err_1':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__if_err_',
	config => ['env.community skyhigh'],
  }
  munin::plugin { 'snmp_gw.skyhgih_if_2':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__if_',
	config => ['env.community skyhigh'],
  }
  munin::plugin { 'snmp_gw.skyhgih_if_err_2':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__if_err_',
	config => ['env.community skyhigh'],
  }
  munin::plugin { 'snmp_gw.skyhgih_if_6':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__if_',
	config => ['env.community skyhigh'],
  }
  munin::plugin { 'snmp_gw.skyhgih_if_err_6':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__if_err_',
	config => ['env.community skyhigh'],
  }
  munin::plugin { 'snmp_gw.skyhgih_if_7':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__if_',
	config => ['env.community skyhigh'],
  }
  munin::plugin { 'snmp_gw.skyhgih_if_err_7':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__if_err_',
	config => ['env.community skyhigh'],
  }
  munin::plugin { 'snmp_gw.skyhgih_if_8':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__if_',
	config => ['env.community skyhigh'],
  }
  munin::plugin { 'snmp_gw.skyhgih_if_err_8':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__if_err_',
	config => ['env.community skyhigh'],
  }

  munin::plugin { 'snmp_gw.skyhgih_if_multi':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__if_multi',
	config => ['env.community skyhigh'],
  }
  munin::plugin { 'snmp_gw.skyhgih_if_netstat':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__netstat',
	config => ['env.community skyhigh'],
  }
  munin::plugin { 'snmp_gw.skyhgih_if_uptime':
    ensure => link,
	target => '/usr/share/munin/plugins/snmp__uptime',
	config => ['env.community skyhigh'],
  }

  munin::master::node_definition { 'gw.skyhigh':
    address => 'gw.skyhigh',
    config  => ['use_node_name no'],
  }
}
