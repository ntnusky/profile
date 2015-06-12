class profile::nfs::server {
  include nfs::server

  file{"/etc/exports":
    ensure => present,
  }

  nfs::server::export{ '/data/shared':
    require => File['/etc/exports'],
    ensure  => 'mounted',
    clients => '172.17.1.0/24(rw,insecure,async,no_root_squash) localhost(rw)'
  }
}
