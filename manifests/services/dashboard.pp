# Installs and configures the management dashboard.
class profile::services::dashboard {
  contain ::profile::services::dashboard::apache
  contain ::profile::services::dashboard::install
  contain ::profile::services::dashboard::database
}
