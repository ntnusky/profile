# Configures a generic haproxy frontend
define profile::services::haproxy::frontend (
  String                   $profile,
  Variant[Integer, String] $port,
  String                   $mode      = 'tcp',
  Variant[Boolean, String] $certfile  = false,
  Hash                     $ftoptions = {},
  Hash                     $bkoptions = {},
) {
  require ::profile::services::haproxy

  # Collect the addresses to bind to; or get false if the address is not used.
  $anycastv4 = lookup("profile::anycast::${profile}::ipv4", {
    'value_type'    => Variant[Stdlib::IP::Address::V4, Boolean],
    'default_value' => false,
  })
  $anycastv6 = lookup("profile::anycast::${profile}::ipv6", {
    'value_type'    => Variant[Stdlib::IP::Address::V6, Boolean],
    'default_value' => false,
  })
  $keepalivedipv4 = lookup("profile::haproxy::${profile}::ipv4", {
    'value_type'    => Variant[Stdlib::IP::Address::V4, Boolean],
    'default_value' => false,
  })
  $keepalivedipv6 = lookup("profile::haproxy::${profile}::ipv6", {
    'value_type'    => Variant[Stdlib::IP::Address::V6, Boolean],
    'default_value' => false,
  })
  $a = concat([], $anycastv4, $anycastv6, $keepalivedipv4, $keepalivedipv6)
  $addresses = delete($a, false)

  # Determine suitable options for http-mode. Addin headers to indicate that the
  # traffic was indeed encrypted in front of the loadbalancer, if that was the
  # case.
  if($mode == 'http') {
    if($certfile) {
      $sslpar = ['ssl', 'crt', $certfile]
      $proto = { 'http-request add-header' => 'X-Forwarded-Proto https' }
    } else {
      $sslpar = []
      $proto = { 'http-request add-header' => 'X-Forwarded-Proto http' }
    }
  } else {
    if($certfile) {
      $sslpar = ['ssl', 'crt', $certfile]
    } else {
      $sslpar = []
    }
    $proto = {}
  }

  # Construct a suitable hash with bind information
  $bind = $addresses.reduce({}) | $memo, $address | {
    $memo + {"${address}:${port}" => $sslpar}
  }

  # Collect lists of servers behind this frontend. Used by the haproxy
  # management script 'haproxy-manage.sh'
  profile::services::haproxy::tools::collect { "bk_${name}": }

  # Define some suitable default options
  $ftbaseoptions = {
    'default_backend' => "bk_${name}",
  }
  $bkbaseoptions = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
    ],
  }

  # Define a haproxy frontend+backend pair
  haproxy::frontend { "ft_${name}":
    bind    => $bind,
    mode    => $mode,
    options => deep_merge($ftbaseoptions, $proto, $ftoptions),
  }
  haproxy::backend { "bk_${name}":
    mode    => $mode,
    options => deep_merge($bkbaseoptions, $bkoptions),
  }
}
