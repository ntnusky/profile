# Open the firewall for certain ports from the external managemnet-networks
# (which is the networks where our administrator-clients, serveres etc. are). 
define profile::firewall::management::external (
  Variant[Integer, Array[Integer], String] $port,
  Enum['tcp', 'udp']                       $transport_protocol = 'tcp',
) {
  ::profile::firewall::custom { $name: 
    port               => $port,
    hiera_key          => 'profile::networks::management::external',
    transport_protocol => $transport_protocol,
  }
}
