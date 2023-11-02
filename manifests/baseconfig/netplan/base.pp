# Initializes the netplan-class 
class profile::baseconfig::netplan::base {
  $ethernets = lookup('profile::baseconfig::network::interfaces', {
    'default_value' => undef,
    'value_type'    => Optional[Hash],
  })

  class { '::netplan':
    # We provide empty dicts so that the netplan-module includes the various
    # headers even though we define the sub-classes elsewhere.
    ethernets => ($ethernets) ? { undef => undef, default => {} },
  }
}
