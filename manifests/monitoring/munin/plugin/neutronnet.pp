# This class installs munin-plugins for our neutronnet nodes.
class profile::monitoring::munin::plugin::neutronnet {
  munin::plugin { 'openstack_neutron_nstypes':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_neutron_nstypes',
    config => [ 'user neutron' ],
  }
}
