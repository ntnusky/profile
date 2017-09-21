# Configure the dashboard clients for DHCP 
class profile::services::dashboard::clients::dns {
  require ::profile::services::dashboard::install

  exec { '/opt/machineadmin/manage.py load_domains':
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/machineadmin'],
  }

  exec { '/opt/machineadmin/manage.py sync_dns':
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/machineadmin'],
  }
}
