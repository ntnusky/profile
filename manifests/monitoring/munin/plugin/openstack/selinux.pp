# Import a custom SELinux module that allow munin-plugins to connect to keystone
class profile::monitoring::munin::plugin::openstack::selinux {
  selinux::module { 'munin_openstack_custom':
    ensure    => 'present',
    source_te => 'puppet:///modules/profile/selinux/munin_openstack_custom.te',
    builder   => 'simple'
  }
}
