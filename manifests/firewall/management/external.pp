# Open the firewall for certain ports from the external managemnet-networks
# (which is the networks where our administrator-clients, serveres etc. are). 
define profile::firewall::management::external (
  Variant[Integer, Array[Integer], String] $port,
  Optional[String]                         $interface = undef,
  Enum['tcp', 'udp']                       $transport_protocol = 'tcp',
) {
  ::profile::firewall::custom { $name: 
    hiera_key          => 'profile::networks::management::external',
    interface          => $interface,
    port               => $port,
    transport_protocol => $transport_protocol,
  }
}
