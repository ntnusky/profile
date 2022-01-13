# Configure systemd-networkd.socket to avoid this bug:
#   https://github.com/systemd/systemd/issues/14417
class profile::baseconfig::network::socketbuffer {
  include ::profile::systemd::reload

  file { '/etc/systemd/system/systemd-networkd.socket.d/':
    ensure => directory,
    mode   => '0755',
    owner  => root,
    group  => root,
  }

  file { '/etc/systemd/system/systemd-networkd.socket.d/buffers.conf':
    ensure  => file,
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => [
      Exec['systemd-reload'],
      Service['systemd-networkd.socket'],
    ],
    require => File['/etc/systemd/system/systemd-networkd.socket.d/'],
    source  => 'puppet:///modules/profile/systemd/networkd.socket.buffers.conf',
  }

  service { 'systemd-networkd.socket':
    ensure   => 'running',
    notify   => Exec['netplan_apply']
    provider => 'systemd',
    require  => [
      File['/etc/systemd/system/systemd-networkd.socket.d/buffers.conf'],
      Exec['systemd-reload'],
    ],
  }
}
