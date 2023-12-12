# Configures an interface to be used by netplan
define profile::baseconfig::netplan::interface (
  Optional[Stdlib::IP::Address::V4::CIDR]         $ipv4       = undef,
  Optional[Stdlib::IP::Address::V6::CIDR]         $ipv6       = undef,
  Optional[Hash]                                  $match      = undef,
  Optional[Array[String]]                         $members    = undef,
  Enum['manual', 'dhcp', 'static', 'shiftleader'] $method     = 'manual',
  Integer                                         $mtu        = 1500,
  Optional[Hash]                                  $parameters = undef,
  Optional[String]                                $parent     = undef,
  Boolean                                         $primary    = false,
  Optional[Integer]                               $priority   = undef,
  Optional[Integer]                               $tableid    = undef,
  Optional[Stdlib::IP::Address::V4]               $v4gateway  = undef,
  Optional[Stdlib::IP::Address::V6]               $v6gateway  = undef,
  Optional[Integer]                               $vlanid     = undef,
) {
  $dns_servers = lookup('profile::dns::resolvers', {
    'default_value' => [],
    'value_type'    => Array,
  })
  # TODO: Remove old default
  $dns_s = lookup('profile::dns::searchdomain', {
    'default_value' => undef,
  })
  $dns_search = lookup('profile::dns::searchdomains', {
    'default_value' => [ $dns_s ],
    'value_type'    => Array,
  })

  include ::profile::baseconfig::netplan::base

  if($method == 'manual') {
    $addressdata = {
      accept_ra => false,
      dhcp4     => false,
    }
  } elsif($method == 'dhcp') {
    if($priority) {
      $priority_real = $priority
    } elsif($tableid) {
      $priority_real = $tableid * 10
    } else {
      $priority_real = 5
    }

    $addressdata = {
      accept_ra       => true,
      dhcp4           => true,
      dhcp4_overrides => {
        'route_metric' => $priority_real,
      },
    }

  } else {
    if($method == 'shiftleader') {
      if($name in $::sl2['server']['interfaces']) {
        $ipv4_real = $::sl2['server']['interfaces'][$name]['ipv4_cidr']
        $ipv6_real = $::sl2['server']['interfaces'][$name]['ipv6_cidr']
      } else {
        fail("No interface named ${name} registered on host in shiftleader!")
      }
    } else {
      $ipv4_real = $ipv4
      $ipv6_real = $ipv6
    }

    # We currently treat IPv4 as mandatory, so fail if no appropriate address is
    # given.
    if($ipv4_real == undef) {
      fail("You must define IPv4 address for ${name} when method is 'static'")
    }

    if(! $v4gateway) {
      $v4routes = []
      $v4policy = []
    } elsif($tableid) {
      # If this is a primary interface, ensure that there is a route in the default 
      # routing-table as well.
      if($primary) {
        $base_route = [{
          'to'  => '0.0.0.0/0',
          'via' => $v4gateway,
        }]
      } else {
        $base_route = []
      }

      $v4routes = [{
        'to'    => '0.0.0.0/0',
        'via'   => $v4gateway,
        'table' => $tableid,
      },{
        'to'    => ip_network($ipv4_real),
        'scope' => 'link',
        'table' => $tableid,
      }] + $base_route
      $v4policy = [{
        'to'    => '0.0.0.0/0',
        'from'  => ip_network($ipv4_real),
        'table' => $tableid,
      }]
    } else {
      $v4routes = [{
        'to'  => '0.0.0.0/0',
        'via' => $v4gateway,
      }]
      $v4policy = []
    }

    if($ipv6) {
      if($tableid) {
        $v6r = [{
          'to'    => ip_network($ipv6_real),
          'scope' => 'link',
          'table' => $tableid,
        }]

        if($v6gateway) {
          $v6routes = [{
            'to'    => '::/0',
            'via'   => $v6gateway,
            'table' => $tableid,
          }] + $v6r
        } else {
          $v6routes = $v6r
        }
        $v6policy = [{
          'to'    => '::/0',
          'from'  => $ipv6_real,
          'table' => $tableid,
        }]
      } else {
        if($v6gateway) {
          $v6routes = [{
            'to'    => '::/0',
            'via'   => $v6gateway,
          }]
        } else {
          $v6routes = []
        }
        $v6policy = []
      }
      $v6ra = false
    } else {
      $v6routes = []
      $v6policy = []
      $v6ra = true
    }

    if(length($v4routes + $v6routes) == 0) {
      $routes_real = undef
    } else {
      $routes_real = $v4routes + $v6routes
    }

    if(length($v4policy + $v6policy) == 0) {
      $policies_real = undef
    } else {
      $policies_real = $v4policy + $v6policy
    }

    $addressdata = {
      accept_ra      => $v6ra,
      match          => $match,
      dhcp4          => false,
      addresses      => [ $ipv4_real, $ipv6_real ] - undef,
      nameservers    => {
        'addresses' => $dns_servers,
        'search'    => $dns_search,
      },
      routes         => $routes_real,
      routing_policy => $policies_real,
    }
  }

  # If it is a bond; create a bond and activate the member interfaces
  if($members) {
    ::netplan::bonds { $name:
      dhcp6      => false,
      interfaces => $members,
      macaddress => $::facts['networking']['interfaces'][$members[0]]['mac'],
      mtu        => $mtu,
      parameters => $parameters,
      *          => $addressdata,
    }

    $members.each | $member | {
      ::netplan::ethernets { $member:
        accept_ra => false,
        dhcp4     => false,
        dhcp6     => false,
        emit_lldp => true,
        mtu       => $mtu,
      }
    }

  # If it is a VLAN-interface, create it
  } elsif ($parent and $vlanid) {
    ::netplan::vlans { $name:
      dhcp6 => false,
      id    => $vlanid,
      link  => $parent,
      mtu   => $mtu,
      *     => $addressdata - ['match'],
    }

  } elsif ($parent or $vlanid) {
    fail('Cannot create VLAN interface withouht both a parent and an ID')

  # If it is a regular interface, simply create the interface.
  } else {
    ::netplan::ethernets { $name:
      dhcp6     => false,
      emit_lldp => true,
      mtu       => $mtu,
      *         => $addressdata,
    }
  }

}
