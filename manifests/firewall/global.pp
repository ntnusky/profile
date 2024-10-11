# Open the firewall for certain ports from any source
define profile::firewall::global (
  Variant[Integer, Array[Integer], String] $port,
  Enum['tcp', 'udp']                       $transport_protocol = 'tcp',
) {
  ::profile::firewall::custom { $name: 
    port               => $port,
    prefixes           => [ '0.0.0.0/0', '::/0' ],
    transport_protocol => $transport_protocol,
  }
}
