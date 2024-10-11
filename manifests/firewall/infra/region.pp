# Open the firewall for certain ports from the region-specific infra-network
define profile::firewall::infra::region (
  Variant[Integer, Array[Integer], String] $port,
  Enum['tcp', 'udp']                       $transport_protocol = 'tcp',
) {
  ::profile::firewall::custom { $name: 
    port               => $port,
    hiera_key          => 'profile::networks::infra',
    transport_protocol => $transport_protocol,
  }
}
