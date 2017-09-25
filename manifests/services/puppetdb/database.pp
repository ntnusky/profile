# Configures a database for puppetdb
class profile::services::puppetdb::database {
  $dbname = hiera('profile::puppetdb::database::name')
  $dbuser = hiera('profile::puppetdb::database::user')
  $dbpass = hiera('profile::puppetdb::database::pass')

  ::postgresql::server::extension { 'pg_trgm':
    database  => $dbname,
  }

  postgresql::server::db { $dbname:
    user     => $dbuser,
    password => $dbpass,
    grant    => 'all',
  }
}
