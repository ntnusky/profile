# Open the firewall for certain ports from any source
define profile::firewall::global (
  Variant[Integer, Array[Integer], String] $port,
  Optional[String]                         $interface = undef,
  Enum['tcp', 'udp']                       $transport_protocol = 'tcp',
) {
  ::profile::firewall::custom { $name: 
    interface          => $interface,
    port               => $port,
    prefixes           => [ '0.0.0.0/0', '::/0' ],
    transport_protocol => $transport_protocol,
  }
}
