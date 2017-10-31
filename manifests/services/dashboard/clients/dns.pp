# Configure the dashboard clients for DHCP 
class profile::services::dashboard::clients::dns {
  require ::profile::services::dashboard::install

  exec { '/opt/shiftleader/manage.py load_domains':
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/shiftleader'],
  }

  exec { '/opt/shiftleader/manage.py sync_dns':
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/shiftleader'],
  }
}
