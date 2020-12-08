# Installs munin-plugins for general monitoring of the host.
class profile::monitoring::munin::plugin::general {
  $interfaces = lookup('profile::baseconfig::network::interfaces', {
    'value_type'    => Variant[Hash,Boolean],
    'default_value' => false,
  })
  $generic = [
    'cpu',
    'df_inode',
    'diskstats',
    'entropy',
    'forks',
    'interrupts',
    'load',
    'memory',
    'open_files',
    'open_inodes',
    'processes',
    'proc_pri',
    'swap',
    'threads',
    'uptime',
    'users',
  ]

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

  case $::osfamily {
    'RedHat': {
      $osspecific = ['yum']
    }
    'Debian': {
      $osspecific = ['ntp_offset']

      munin::plugin { 'apt':
        ensure => link,
        config => ['user root'],
      }
    }
    default: {
      $osspecific = []
    }
  }

  $plugins =  $osspecific + $generic
  $plugins.each | $plugin | {
    munin::plugin { $plugin:
      ensure => link,
    }
  }

  munin::plugin { 'df':
    ensure       => link,
    config       => ['env.warning 80', 'env.critical 90'],
    config_label => 'df*',
  }
  munin::plugin { 'multiping':
    ensure => link,
    config => [
      'env.host ntnu.no gjovik-gw1.uninett.no ntnu-gw-l0.nettel.ntnu.no',
    ],
  }
}
