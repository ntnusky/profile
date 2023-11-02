# Configures an interface to be used by netplan
define profile::baseconfig::netplan::interface (
  Optional[Stdlib::IP::Address::V4::CIDR] $ipv4      = undef,
  Optional[Stdlib::IP::Address::V6::CIDR] $ipv6      = undef,
  Hash                                    $match     = {},
  Enum['manual', 'dhcp', 'static']        $method    = 'manual',
  Integer                                 $mtu       = 1500,
  Optional[Integer]                       $tableid   = undef,
  Optional[Stdlib::IP::Address::V4]       $v4gateway = undef,
  Optional[Stdlib::IP::Address::V6]       $v6gateway = undef,
) {
  $dns_servers = lookup('profile::dns::nameservers', {
    'default_value' => undef,
  })
  $dns_search = lookup('profile::dns::searchdomain', {
    'default_value' => undef,
  })

  include ::profile::baseconfig::netplan::base

  if($method == 'manual') {
    ::netplan::ethernets { $name:
      accept_ra => false,
      dhcp4     => false,
      dhcp6     => false,
      emit_lldp => true,
      mtu       => $mtu,
    }
  } elsif($method == 'dhcp') {
    ::netplan::ethernets { $name:
      dhcp4     => true,
      dhcp6     => false,
      emit_lldp => true,
    }
  } else {
    # We currently treat IPv4 as mandatory, so fail if no appropriate address is
    # given.
    if($ipv4 == undef) {
      fail("You must define IPv4 address for ${name} when method is 'static'")
    }

    if(! $v4gateway) {
      $v4routes = []
      $v4policy = []
    } elsif($tableid) {
      $v4routes = [{
        'to'    => '0.0.0.0/0',
        'via'   => $v4gateway,
        'table' => $tableid,
      },{
        'to'    => $ipv4,
        'scope' => 'link',
        'table' => $tableid,
      }]
      $v4policy = [{
        'to'    => '0.0.0.0/0',
        'from'  => $ipv4,
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
          'to'    => $ipv6,
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
          'from'  => $ipv6,
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
    } else {
      $v6routes = []
      $v6policy = []
    }

    ::netplan::ethernets { $name:
      match          => $match,
      emit_lldp      => true,
      dhcp4          => false,
      dhcp6          => false,
      addresses      => [ $ipv4, $ipv6 ] - undef,
      nameservers    => {
        'addresses' => split($dns_servers, ' '),
        'search'    => [ $dns_search ],
      },
      mtu            => $mtu,
      routes         => $v4routes + $v6routes,
      routing_policy => $v4policy + $v6policy,
    }
  }
}
