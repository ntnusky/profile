# Opens the firewall for the ceph REST service.
class profile::ceph::firewall::rest {
  require ::profile::baseconfig::firewall

  ::profile::baseconfig::firewall::service::infra { 'Ceph-REST':
    protocol => 'tcp',
    port     => 8003,
  }
}
