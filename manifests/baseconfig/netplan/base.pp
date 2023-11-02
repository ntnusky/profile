# Initializes the netplan-class 
class profile::baseconfig::netplan::base {
  $ethernets = lookup('profile::baseconfig::network::interfaces', {
    'default_value' => undef,
    'value_type'    => Optional[Hash],
  })
  $bonds = lookup('profile::baseconfig::network::bonds', {
    'default_value' => undef,
    'value_type'    => Optional[Hash],
  })

  if($bonds != undef or $ethernets != undef) {
    $eth = {} 
  } else {
    $eth = undef 
  }

  class { '::netplan':
    # We provide empty dicts so that the netplan-module includes the various
    # headers even though we define the sub-classes elsewhere.
    bonds     => ($bonds) ? { undef => undef, default => {} },
    ethernets => $eth, 
  }
}
