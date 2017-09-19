# Configure the dashboard clients for DHCP 
class profile::services::dashboard::clients::dns {
  require ::profile::services::dashboard::install::onlycode
  require ::profile::services::dashboard::config

  $path = '/opt/machineadmin-code'

  exec { "${path}/manage.py load_domains":
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/machineadmin-code'],
  }
}
