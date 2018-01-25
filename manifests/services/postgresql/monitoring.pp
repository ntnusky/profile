# Various monitoring classes for PostgreSQL
class profile::services::postgresql::monitoring {

  $installsensu = hiera('profile::sensu::install', true)
  if ($installsensu) {
    include ::profile::sensu::plugin::postgres
  }
}
