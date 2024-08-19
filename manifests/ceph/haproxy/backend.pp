class profile::ceph::haproxy::backend {
  include ::profile::ceph::firewall::rest

  ::profile::services::haproxy::backend { 'Ceph-REST':
    backend   => 'bk_Ceph-REST',
    interface => $::sl2['server']['primary_interface']['name'],
    port      => '8003',
  }
}

