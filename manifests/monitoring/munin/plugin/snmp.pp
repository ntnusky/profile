# This class sets up the needed munin-plugins to monitor a switch/router over
# SNMP.
class profile::monitoring::munin::plugin::snmp {
  $devices = lookup('profile::snmp::devices', {
    'value_type'    => Hash,
    'default_value' => {},
  })

  $devices.each | $host, $data | {
    munin::master::node_definition { $host:
      address => '127.0.0.1',
      config  => ['use_node_name no'],
    }

    $community = $data['community']

    $data['plugins'].each | $plugin | {
      munin::plugin { "snmp_${host}_${plugin}":
        ensure => link,
        target => "/usr/share/munin/plugins/snmp__${plugin}",
        config => ["env.community ${community}"],
      }
    }

    $data['interfaces'].each | $id, $data | {
      munin::plugin { "snmp_${host}_if_${id}":
        ensure => link,
        target => '/usr/share/munin/plugins/snmp__if_',
        config => ["env.community ${community}"],
      }
      munin::plugin { "snmp_${host}_if_err_${id}":
        ensure => link,
        target => '/usr/share/munin/plugins/snmp__if_err_',
        config => ["env.community ${community}"],
      }
    }
  }
}
