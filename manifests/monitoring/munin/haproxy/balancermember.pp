# Define balancer members for munin haproxy backend
class profile::monitoring::munin::haproxy::balancermember {
  $management_if = lookup('profile::interfaces::management', String)

  ::profile::services::haproxy::backend { 'Munin':
    backend   => 'bk_munin',
    interface => $management_if,
    options   => 'check inter 5s',
    port      => 80,
  }
}
