class profile::openstack::keystone {
  $password = hiera("profile::mysql::keystonepass")
  $allowed_hosts = hiera("profile::mysql::allowed_hosts")
  
  include ::profile::openstack::repo
  
  class { "::keystone::db::mysql":
    user          => 'keystone',
    password      => $password,
    allowed_hosts => $allowed_hosts,
    dbname        => 'keystone',
    require       => Anchor['profile::mysqlcluster::end'],
  }

  #class{'keystone':
  #}
    
}
