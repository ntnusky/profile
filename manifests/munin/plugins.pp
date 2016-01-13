define setMuninIf {
  munin::plugin { if_$name:
    ensure => 'link,
	target => 'if_'
  }
  munin::plugin { if_err_$name:
    ensure => 'link,
	target => 'if_err_'
  }
}

class profile::munin::plugins {
  $interfacesToConfigure = hiera("profile::interfaces", false)
  if($interfacesToConfigure) {
    setMuninIf { $interfacesToConfigure: }
  }

  munin::plugin { 'apt':
    ensure => link,
  }
  munin::plugin { 'cpu':
    ensure => link,
  }
  munin::plugin { 'df':
    ensure => link,
  }
  munin::plugin { 'df_inode':
    ensure => link,
  }
  munin::plugin { 'diskstats':
    ensure => link,
  }
  munin::plugin { 'entropy':
    ensure => link,
  }
  munin::plugin { 'forks':
    ensure => link,
  }
  munin::plugin { 'interrupts':
    ensure => link,
  }
  munin::plugin { 'load':
    ensure => link,
  }
  munin::plugin { 'memory':
    ensure => link,
  }
  munin::plugin { 'netstat':
    ensure => link,
  }
  munin::plugin { 'open_files':
    ensure => link,
  }
  munin::plugin { 'open_inodes':
    ensure => link,
  }
  munin::plugin { 'processes':
    ensure => link,
  }
  munin::plugin { 'proc_pri':
    ensure => link,
  }
  munin::plugin { 'swap':
    ensure => link,
  }
  munin::plugin { 'threads':
    ensure => link,
  }
  munin::plugin { 'uptime':
    ensure => link,
  }
  munin::plugin { 'users':
    ensure => link,
  }
}
