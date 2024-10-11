# Open the firewall for certain ports from all the infra-networks in all our
# regions.
define profile::firewall::infra::all (
  Variant[Integer, Array[Integer], String] $port,
  Optional[String]                         $interface = undef,
  Enum['tcp', 'udp']                       $transport_protocol = 'tcp',
) {
  ::profile::firewall::custom { $name: 
    hiera_key          => 'profile::networks::infra::all',
    interface          => $interface,
    port               => $port,
    transport_protocol => $transport_protocol,
  }
}
