# Configure libvirt hosts
class profile::services::libvirt {
  contain ::profile::services::libvirt::pools
  contain ::profile::services::libvirt::networks

  class { '::libvirt':
    deb_default => {
      'libvirtd_opts' => '',
    },
    mdns_adv    => false,
    before      => [
      Class['::profile::services::libvirt::networks'],
      Class['::profile::services::libvirt::pools'],
    ],
  }
}
