# This class installs the munin plugins which monitors mysql statistics 
class profile::monitoring::munin::plugin::mysql {
  $pw = hiera('profile::mysqlcluster::root_password')
  ensure_packages ( [
      'libcache-cache-perl',
    ], {
      'ensure' => 'present',
    }
  )
  
  $plugins = [
    'bin_relay_log',
    'commands',
    'connections',
    'files_tables',
    'innodb_bpool',
    'innodb_bpool_act',
    'innodb_io',
    'innodb_log',
    'innodb_rows',
    'innodb_semaphores',
    'innodb_tnx',
    'myisam_indexes',
    'network_traffic',
    'qcache',
    'qcache_mem',
    'select_types',
    'slow',
    'sorts',
    'table_locks',
    'tmp_tables',
  ]
  $plugins.each |$plugin| {
    munin::plugin { "mysql_${plugin}":
      ensure => link,
      target => 'mysql_',
      config => ["env.mysqlpassword ${pw}"],
    }
  }
  munin::plugin { 'mysql_threads':
    ensure => link,
    config => ["env.mysqlopts --user=root --password=${pw}"],
  }
  munin::plugin { 'mysql_queries':
    ensure => link,
    config => ["env.mysqlopts --user=root --password=${pw}"],
  }
}
