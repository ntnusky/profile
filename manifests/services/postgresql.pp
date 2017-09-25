# This class installs and configures the postgresql cluster
class profile::services::postgresql {
  contain profile::services::postgresql::keepalived
  contain profile::services::postgresql::pgpool
  contain profile::services::postgresql::server
}
