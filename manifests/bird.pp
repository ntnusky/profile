# Installs and configures the bird routing-daemon
class profile::bird {
  include ::profile::bird::ipv4
  include ::profile::bird::ipv6

  $zabbixservers = lookup('profile::zabbix::agent::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })
  # If the array contains at least one element:
  if($zabbixservers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    include ::profile::zabbix::agent::bird
  }
}
