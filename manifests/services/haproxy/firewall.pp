# Default firewall rules for the haproxy status-page
class profile::services::haproxy::firewall {
  # Let our admin-clients see the statuspage
  ::profile::firewall::management::external { 'haproxy-status':
    port => 9000,
  }

  # Let our zabbix-servers discover the service
  ::profile::firewall::management::custom { 'haproxy-status-infra':
    port      => 9000,
    hiera_key => 'profile::zabbix::agent::servers',
  }
}
