# This class installs and configures the postgresql cluster
class profile::services::postgresql {
  contain profile::services::postgresql::backup
  contain profile::services::postgresql::firewall
  contain profile::services::postgresql::keepalived
  contain profile::services::postgresql::server
}
