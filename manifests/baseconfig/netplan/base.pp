# Initializes the netplan-class 
class profile::baseconfig::netplan::base {
  $ethernets = lookup('profile::baseconfig::network::interfaces', {
    'default_value' => undef,
    'value_type'    => Optional[Hash],
  })

  class { '::netplan':
    ethernets => ($ethernets) ? { undef => undef, default => {} },
  }
}
