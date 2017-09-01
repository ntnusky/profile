# Installs and configures the management dashboard.
class profile::services::dashboard {
  require ::profile::services::apache

  contain ::profile::services::dashboard::apache
  contain ::profile::services::dashboard::config
  contain ::profile::services::dashboard::install
  contain ::profile::services::dashboard::packages
}
