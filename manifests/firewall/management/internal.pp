# Open the firewall for certain ports from the internal managemnet-networks
# (which is the networks where our management-servers and such resides). 
define profile::firewall::management::internal (
  Variant[Integer, Array[Integer], String] $port,
  Optional[String]                         $interface = undef,
  Enum['tcp', 'udp']                       $transport_protocol = 'tcp',
) {
  ::profile::firewall::custom { $name: 
    hiera_key          => 'profile::networks::management::internal',
    interface          => $interface,
    port               => $port,
    transport_protocol => $transport_protocol,
  }
}
