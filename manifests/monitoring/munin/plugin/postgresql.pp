# This class installs munin plugins for monitoring PostgreSQL statistics
class profile::monitoring::munin::plugin::postgresql {
  $databases = hiera_array('profile::munin::postgresql::databases', undef)

  ensure_packages([
      'libdbd-pg-perl',
    ], {
      'ensure' => 'present',
    }
  )

  munin::plugin { 'postgres_bgwriter':
    ensure => link,
    config => [ 'user postgres' ],
  }
  munin::plugin { 'postgres_cache_ALL':
    ensure => link,
    target => 'postgres_cache_',
    config => [ 'user postgres' ],
  }
  munin::plugin { 'postgres_connections_db':
    ensure => link,
    config => [ 'user postgres' ],
  }
  munin::plugin { 'postgres_locks_ALL':
    ensure => link,
    target => 'postgres_locks_',
    config => [ 'user postgres' ],
  }
  munin::plugin { 'postgres_querylength_ALL':
    ensure => link,
    target => 'postgres_querylength_',
    config => [ 'user postgres' ],
  }
  munin::plugin { 'postgres_size_ALL':
    ensure => link,
    target => 'postgres_size_',
    config => [ 'user postgres' ],
  }
  munin::plugin { 'postgres_transactions_ALL':
    ensure => link,
    target => 'postgres_transactions_',
    config => [ 'user postgres' ],
  }
  munin::plugin { 'postgres_users':
    ensure => link,
    config => [ 'user postgres' ],
  }
  munin::plugin { 'postgres_xlog':
    ensure => link,
    config => [ 'user postgres' ],
  }

  if ( $databases ) {
    $databases.each |$database| {
      munin::plugin { "postgres_tuples_${database}":
        ensure => link,
        target => 'postgres_tuples_',
        config => [ 'user postgres' ],
      }
      munin::plugin { "postgres_scans_${database}":
        ensure => link,
        target  => 'postgres_scans_',
        config => [ 'user postgres' ],
      }
    }
  }
}
