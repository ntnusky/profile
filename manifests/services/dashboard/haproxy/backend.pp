# Haproxy backend for shiftleader
class profile::services::dashboard::haproxy::backend {
  $if = lookup('profile::interfaces::management', String)

  ::profile::services::haproxy::backend { 'Shiftleader':
    backend   => 'bk_shiftleader',
    interface => $if,
    options   => [ 'check inter 5s', ],
    port      => 80,
  }
}
