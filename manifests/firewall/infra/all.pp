# Open the firewall for certain ports from all the infra-networks in all our
# regions.
define profile::firewall::infra::all (
  Variant[Integer, Array[Integer], String] $port,
  Enum['tcp', 'udp']                       $transport_protocol = 'tcp',
) {
  ::profile::firewall::custom { $name: 
    port               => $port,
    hiera_key          => 'profile::networks::infra::all',
    transport_protocol => $transport_protocol,
  }
}
