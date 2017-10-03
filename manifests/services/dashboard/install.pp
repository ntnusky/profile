# Installs the dashboard
class profile::services::dashboard::install {
  require ::profile::services::dashboard::config
  require ::profile::services::dashboard::packages

  contain ::profile::services::dashboard::install::code
  include ::profile::services::dashboard::clients::dns
  include ::profile::services::dashboard::clients::dhcp
}
