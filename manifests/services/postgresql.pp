# This class installs and configures the postgresql cluster
class profile::services::postgresql {
  contain profile::services::postgresql::server
}
