# Sensu checks for ceph-nodes
class profile::sensu::checks::ceph {
  sensu::check { 'ceph-health':
    command     => 'sudo check-ceph.rb -d',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'roundrobin:ceph' ],
  }
}
