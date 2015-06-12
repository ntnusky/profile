class profile::users {
  group { 'users':
    ensure => present,
    gid => 700,
  }
  
  include ::profile::users::eigil
  include ::profile::users::erikh
}
