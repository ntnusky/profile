# Open the firewall for certain ports from the internal managemnet-networks
# (which is the networks where our management-servers and such resides). 
define profile::firewall::management::internal (
  Variant[Integer, Array[Integer], String] $port,
  Enum['tcp', 'udp']                       $transport_protocol = 'tcp',
) {
  ::profile::firewall::custom { $name: 
    port               => $port,
    hiera_key          => 'profile::networks::management::internal',
    transport_protocol => $transport_protocol,
  }
}
