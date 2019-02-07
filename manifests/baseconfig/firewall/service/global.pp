# Punch a hole in the firewall to allow global access to a service
define profile::baseconfig::firewall::service::global (
  Variant[Integer, Array[Integer]] $port,
  String                           $protocol,
) {
  require ::profile::baseconfig::firewall

  firewall { "5 Accept global v4 access to service ${name}":
    proto  => $protocol,
    dport  => $port,
    action => 'accept',
  }

  firewall { "5 Accept global v6 access to service ${name}":
    proto    => $protocol,
    dport    => $port,
    action   => 'accept',
    provider => 'ip6tables',
  }
}
