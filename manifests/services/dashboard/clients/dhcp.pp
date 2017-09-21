# Configure the dashboard clients for DHCP 
class profile::services::dashboard::clients::dhcp {
  require ::profile::services::dashboard::install

  exec { '/opt/machineadmin/manage.py load_subnets':
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/machineadmin'],
  }

  exec { '/opt/machineadmin/manage.py sync_dhcp':
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/machineadmin'],
  }
}
