# Configure the dashboard clients for DHCP 
class profile::services::dashboard::clients::dhcp {
  require ::profile::services::dashboard::install::onlycode
  require ::profile::services::dashboard::config

  $path = '/opt/machineadmin-code'

  exec { "${path}/manage.py load_subnets":
    refreshonly => true,
    subscribe   => Class['profile::services::dashboard::install::onlycode'],
  }

  exec { "${path}/manage.py sync_dhcp":
    refreshonly => true,
    subscribe   => Class['profile::services::dashboard::install::onlycode'],
  }
}
