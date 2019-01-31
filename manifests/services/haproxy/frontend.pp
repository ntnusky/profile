# Configures a generic haproxy frontend
define profile::services::haproxy::frontend (
  String  $profile,
  Integer $port,
  Hash    $ftoptions = {},
  Hash    $bkoptions = {},
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

  # Construct a suitable hash with bind information
  $bind = $addresses.reduce({}) | $memo, $address | {
    $memo + {"${address}:${port}" => []}
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
    mode    => 'tcp',
    options => deep_merge($ftbaseoptions, $ftoptions),
  }
  haproxy::backend { "bk_${name}":
    mode    => 'tcp',
    options => deep_merge($bkbaseoptions + $bkoptions),
  }
}
