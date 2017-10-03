# Installs the dashboard
class profile::services::dashboard::install {
  require ::profile::services::dashboard::config
  require ::profile::services::dashboard::packages

  contain ::profile::services::dashboard::install::code
  contain ::profile::services::dashboard::clients::dns
  contain ::profile::services::dashboard::clients::dhcp
}
