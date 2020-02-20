# This class installs relevant munin-plugins for our neutronapi-nodes
class profile::monitoring::munin::plugin::openstack::neutronapi {
  $externalnets = lookup('ntnuopenstack::neutron::networks::external', {
    'value_type' => Hash,
  })
  $externalnames = $externalnets.map | $key, $data | { $data['name'] }
  $externals = join($externalnames, ' ')

  ::profile::monitoring::munin::plugin::openstack::generic {
      'openstack_floatingip':
    keystone_user => 'admin',
    plugin_user   => 'neutron',
  }

  ::profile::monitoring::munin::plugin::openstack::generic {
      'openstack_ipuse':
    keystone_user       => 'admin',
    plugin_user         => 'neutron',
    plugin_extra_config => [
      "env.EXTERNALS ${externals}",
    ],
  }

  $externalnets.each | $key, $data | {
    $net = $data['name']
    ::profile::monitoring::munin::plugin::openstack::generic {
        "openstack_ipuse_${net}":
      keystone_user => 'admin',
      plugin_file   => 'openstack_ipuse_',
      plugin_user   => 'neutron',
    }
  }
}
