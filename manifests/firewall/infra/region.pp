# Open the firewall for certain ports from the region-specific infra-network
define profile::firewall::infra::region (
  Variant[Integer, Array[Integer], String] $port,
  Optional[String]                         $interface = undef,
  Enum['tcp', 'udp']                       $transport_protocol = 'tcp',
) {
  ::profile::firewall::custom { $name: 
    hiera_key          => 'profile::networks::infra',
    interface          => $interface,
    port               => $port,
    transport_protocol => $transport_protocol,
  }
}
