# Configure libvirt hosts
class profile::services::libvirt {
  contain ::profile::services::libvirt::logging
  contain ::profile::services::libvirt::networks
  contain ::profile::services::libvirt::pools

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
