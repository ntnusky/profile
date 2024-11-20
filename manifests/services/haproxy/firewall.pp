# Default firewall rules for the haproxy status-page
class profile::services::haproxy::firewall {
  ::profile::firewall::management::external { 'haproxy-status':
    port => 9000,
  }
}
