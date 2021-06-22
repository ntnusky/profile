# Configures a generic haproxy backend
define profile::services::haproxy::backend (
  String                         $backend,
  Stdlib::Port                   $port,
  String                         $hostname = $::hostname,
  String                         $interface = undef,
  Stdlib::IP::Address::Nosubnet  $ip = undef,
  Variant[Array[String], String] $options = [],
) {
  # Fail the run if neither IP or interface of the backend is defined.
  if($ip == undef and $interface == undef) {
    fail('Either IP or Interface must be set for a haproxy-backend')
  }

  # If the interface is set, read an IP-address from hiera, or from the facts,
  # to determine an IP for the backend.
  if($interface != undef) {
    $auto_ip = $::facts['networking']['interfaces'][$interface]['ip']
    $real_ip = lookup(
      "profile::baseconfig::network::interfaces.${interface}.ipv4.address", {
        'value_type'    => Stdlib::IP::Address::V4,
        'default_value' => $auto_ip,
      }
    )
  }

  # If the IP is set, use it.
  if($ip != undef) {
    $real_ip = $ip
  }

  # To actually register the backend is globally opt-outable, so check if we
  # actually should do anything.
  $register_loadbalancer = lookup('profile::haproxy::register', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  if($register_loadbalancer) {
    # Make a registration for our helper-scripts.
    profile::services::haproxy::tools::register { "${name}-${::fqdn}":
      servername  => $hostname,
      backendname => $backend,
    }

    # Make a registration for the loadbalancer.
    @@haproxy::balancermember { "${name}-${::fqdn}":
      listening_service => $backend,
      server_names      => $hostname,
      ipaddresses       => $real_ip,
      ports             => $port,
      options           => $options,
    }
  }
}
