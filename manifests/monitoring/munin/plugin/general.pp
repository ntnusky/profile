# Installs munin-plugins for general monitoring of the host.
class profile::monitoring::munin::plugin::general {
  $interfaces = lookup('profile::baseconfig::network::interfaces', {
    'value_type'    => Variant[Hash,Boolean],
    'default_value' => false,
  })
  if($interfaces) {
    keys($interfaces).each | $if | {
      munin::plugin { "if_${if}":
        ensure => link,
        target => 'if_',
        config => ['user root', 'env.speed 10000'],
      }
      munin::plugin { "if_err_${if}":
        ensure => link,
        target => 'if_err_',
        config => ['user nobody'],
      }
    }
  }

  munin::plugin { 'apt':
    ensure => link,
    config => ['user root'],
  }
  munin::plugin { 'cpu':
    ensure => link,
  }
  munin::plugin { 'df':
    ensure       => link,
    config       => ['env.warning 80', 'env.critical 90'],
    config_label => 'df*',
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
  munin::plugin { 'multiping':
    ensure => link,
    config => [
      'env.host ntnu.no gjovik-gw1.uninett.no ntnu-gw-l0.nettel.ntnu.no',
    ],
  }
  munin::plugin { 'netstat':
    ensure => link,
  }
  munin::plugin { 'ntp_offset':
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
