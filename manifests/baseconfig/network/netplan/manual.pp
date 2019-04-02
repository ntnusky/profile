# Hack to configure a 'manual' interface with netplan
# Due to https://bugs.launchpad.net/netplan/+bug/1728134
# and https://bugs.launchpad.net/netplan/+bug/1763608
# With netplan it is impossible to configure an interface to
# be 'up' without anymore configuration...

define profile::baseconfig::network::netplan::manual (
  $interface = $name,
) {
  file { "/etc/systemd/network/${name}.network":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('profile/manual-netplan-nic.erb'),
    notify  => Service['systemd-networkd'],
  }
  service { 'systemd-networkd':
    ensure    => 'running',
  }
}
