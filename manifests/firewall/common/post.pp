# This class installs the last firewall-rule, basically controlling the
# default-behaviour. This should default to drop; but might also be 'log' to aid
# in debugging.
class profile::firewall::common::post {
  $action = lookup('profile::firewall::action::final', {
    'default_value' => 'drop',
    'value_type'    => Enum['drop', 'log', 'reject'],
  })

  if($action == 'log') {
    firewall { '999 drop all':
      proto      => 'all',
      jump       => 'LOG',
      log_level  => '5',
      log_prefix => 'FW-DROP',
      before     => undef,
    }
    firewall { '999 ipv6 drop all':
      proto      => 'all',
      jump       => 'LOG',
      log_level  => '5',
      log_prefix => 'FW-DROP',
      provider   => 'ip6tables',
      before     => undef,
    }
  } else {
    firewall { '999 drop all':
      proto  => 'all',
      jump   => $action,
      before => undef,
    }
    firewall { '999 ipv6 drop all':
      proto    => 'all',
      jump     => $action,
      provider => 'ip6tables',
      before   => undef,
    }
  }
}
