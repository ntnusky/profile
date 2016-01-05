class profile::munin::node {
  $management_if = hiera("profile::interfaces::management")
  $management_ip = getvar("::ipaddress_${management_if}")

  class {'::munin::node':
    bind_address => $management_ip,
	allow => "172.17.1.11",
  }
}
