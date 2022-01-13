# Configure systemd-networkd.socket to avoid this bug:
#   https://github.com/systemd/systemd/issues/14417
class profile::baseconfig::network::socketbuffer {
  systemd::dropin_file { 'buffers.conf':
    unit   => 'systemd-networkd.socket',
    source => 'puppet:///modules/profile/systemd/networkd.socket.buffers.conf',
    notify => Service['systemd-networkd.socket'],
  }

  service { 'systemd-networkd.socket':
    ensure   => 'running',
    notify   => Exec['netplan_apply'],
    provider => 'systemd',
    require  => Systemd::Dropin_file['buffers.conf'],
  }
}
